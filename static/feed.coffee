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

                foundImage = false
                for link in data.data.children

                    deferred = @_formatUrl link.data.url

                    continue unless deferred

                    foundImage = true
                    @_addImageOnDone deferred, link.data

                @_error 'No images found.' unless foundImage

            error: =>

                @_error 'Error loading subreddit.'

            complete: (xhr) =>

                @_loading = false

    _wrapDeferred: (url) -> new $.Deferred().resolve url

    _formatUrl: (url) ->

        return @_wrapDeferred url if Utils.isImageUrl url

        [host, hash] = Utils.urlInfo url

        switch host
            when 'imgur'
                
                deferred = new $.Deferred()
                $.ajax
                    type: 'GET'
                    url: "http://api.imgur.com/2/image/#{hash}.json"
                    success: (data) =>
                        deferred.resolve data.image?.links.original

                deferred

            when 'quickmeme' then @_wrapDeferred "http://i.qkme.me/#{hash}.jpg"

    _resetPagination: ->

        # Used to get more pages from the API call.
        @_count = 0
        @_after = null
        @_resultsPerPage = 25

    _addImageOnDone: (deferred, data) ->

        deferred.done (url) =>

            return unless url

            @_addImage
                link: "http://reddit.com/#{data.permalink}"
                title: data.title
                url: url

    _addImage: (data) ->

        template = $('#tmpl-image-wrap').text()
        node = $(Mustache.render template, data)

        image = new Image()
        $(image).load =>

            image.title = data.title

            link = node.find('.image')
            link.append image

            node.find('.showModal').click (event) =>
                event.preventDefault()
                event.stopPropagation()
                @toggleModal image

            node.insertBefore @_loadingNode

            pos = Math.floor $(image).position().top - @_imageOffset
            @_imageYPos.push pos
            @_pos2image[pos] = image

        image.src = data.url

    _setupInfiniteScroll: ->

        @_loadingNode = $('<div class="loading"></div>')
        @_container.append @_loadingNode

        $(window).scroll =>

            if window.scrollY is 0
                @_showIndex = 0

            else if window.scrollY is $(document).height() - $(window).height()
                @_showIndex = @_imageYPos.length - 1

            if window.scrollY > @_imageYPos[@_showIndex + 1]
                @_showIndex += 1

            else if window.scrollY < @_imageYPos[@_showIndex]
                @_showIndex -= 1

            return if @_loading
            return if (@_imageYPos.length - @_showIndex) > @_loadThreshold

            @_loadUrls()
