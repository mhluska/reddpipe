class window.Feed

    constructor: (container) ->

        @_resetImageIndices()
        @_resetPagination()

        @_container = $(container)
        @_containerWidth = @_container.width()
        @_loadThreshold = 5
        @_imageOffset = 20

        # A callback to execute if the feed encounters an error.
        @_error = ->

        @_container.addClass 'feed'
        @_setupInfiniteScroll()
        @_setupIndexAutoUpdate()

        $(window).click => @_hideModal()
        $(window).keydown (event) =>
            @_hideModal() if event.which in [13, 27]

    setSubreddit: (@subreddit) ->

        @_resetImageIndices()
        @_resetPagination()
        @_container
            .html('')
            .append @_loadingNode

        @_loadUrls()

    error: (callback) ->
        
        @_error = (message) ->

            @_loadingNode.text message
            callback()
            return

    showPrev: ->

        return if @_showIndex is 0

        if window.scrollY is @_imageYPos[@_showIndex]
            @_showIndex -= 1

        @_showImage()

    showNext: ->

        if @_showIndex is @_imageYPos.length - 1
            $(window).scrollTop $(document).height()
            return

        @_showIndex += 1

        @_showImage()

    toggleModal: do ->

        placeholder = null
        maxedImage = null

        overlay = $('<div class="overlay"></div>')
    
        (image) ->

            # If we're at the top of the page, use the first image for
            # convenience.
            @showNext() if @_showIndex is 0
            image = @_pos2image[@_imageYPos[@_showIndex]] unless image
            return unless image

            image = $(image)

            if @_showingModal
                # Just put the image back in its spot.
                placeholder.replaceWith maxedImage
                overlay.remove()

            else
                # Replace the image with a placeholder of the same size.
                placeholder = $('<div></div>')
                    .width(image.width())
                    .height(image.height())

                image.replaceWith placeholder

                # Move the image to the document root and make it as big as 
                # possible.
                overlay.appendTo document.body
                overlay.append image
                
                maxedImage = image

            @_showingModal = !@_showingModal

    _hideModal: ->

        @toggleModal() if @_showingModal

    _showImage: ->

        pos = @_imageYPos[@_showIndex]

        return unless pos?

        $(window).scrollTop pos

        if @_showingModal

            @toggleModal()
            @toggleModal()

    _resetImageIndices: ->

        # Used for navigating by images with page up/down.
        @_imageYPos = [0]
        @_showIndex = 0

        # Used for maximizing an image with spacebar is pressed
        @_pos2image = 0: null
        @_showingModal = false

    _loadUrls: ->

        return if @_loading

        @_loading = true
        @_loadingNode.text 'loading'
        @_count += @_resultsPerPage

        url = "http://www.reddit.com/r/#{@subreddit}"

        params = "limit=#{@_resultsPerPage}&count=#{@_count}"
        params += "&after=#{@_after}" if @_after

        # TODO: Fix error from jQuery when data type doesn't come back as json.
        $.ajax
            type: 'GET'
            url: "#{url}.json?#{params}"
            dataType: 'jsonp'
            jsonp: 'jsonp'
            timeout: 4000

            success: (data) =>

                @_after = data.data.after

                imageData = []
                for link in data.data.children

                    url = @_formatUrl link.data.url
                    continue unless url
                    imageData.push
                        link: "http://reddit.com/#{link.data.permalink}"
                        title: link.data.title
                        url: url

                @_error 'No images found.' unless imageData.length

                @_addImage image for image in imageData

            error: =>

                @_error 'Error loading subreddit.'

            complete: (xhr) =>

                @_loading = false

    _formatUrl: (url) ->

        if Utils.isImageUrl url
            url

        else if Utils.isImgurUrl url
            "#{url}.jpg"

    _resetPagination: ->

        # Used to get more pages from the API call.
        @_count = 0
        @_after = null
        @_resultsPerPage = 25

    _addImage: (data) ->

        template = $('#tmpl-image-wrap').text()
        node = $(Mustache.render template, data)

        image = new Image()
        $(image).load =>

            return if image.width < @_containerWidth

            image.title = data.title

            link = node.find('.image')
            link.append image

            node.find('.showModal').click => @toggleModal image

            node.insertBefore @_loadingNode

            pos = Math.floor $(image).position().top - @_imageOffset
            @_imageYPos.push pos
            @_pos2image[pos] = image

        image.src = data.url

    _setupInfiniteScroll: ->

        @_loadingNode = $('<div class="loading"></div>')
        @_container.append @_loadingNode

        $(window).scroll =>

            return if @_loading

            return if (@_imageYPos.length - @_showIndex) > @_loadThreshold

            @_loadUrls()

    _setupIndexAutoUpdate: ->

        $(window).scroll =>

            if window.scrollY > @_imageYPos[@_showIndex + 1]
                @_showIndex += 1

            else if window.scrollY < @_imageYPos[@_showIndex]
                @_showIndex -= 1

