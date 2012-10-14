class window.Feed

    constructor: (container) ->

        @_resetImageIndices()
        @_resetPagination()

        @_container = $(container)
        @_containerWidth = @_container.width()
        @_loadThreshold = 1000
        @_imageOffset = 20

        # A callback to execute if the feed encounters an error.
        @_error = ->

        @_container.addClass 'feed'
        @_setupInfiniteScroll()
        @_setupIndexAutoUpdate()

    setSubreddit: (@subreddit) ->

        @_resetImageIndices()
        @_resetPagination()
        @_loadingNode.text 'loading'
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

        return if @_showIndex is @_imageYPos.length - 1

        @_showIndex += 1

        @_showImage()

    _showImage: ->

        pos = @_imageYPos[@_showIndex]

        return unless pos?

        $(window).scrollTop pos

    _resetImageIndices: ->

        # Used for navigating by images with page up/down.
        @_imageYPos = [0]
        @_showIndex = 0

    _loadUrls: ->

        return if @_loading

        @_loading = true
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

                links = (link.data for link in data.data.children when \
                    Utils.isImageUrl link.data.url)

                @_error 'No images found.' unless links.length

                for link in links
                    @_addImage
                        link: "http://reddit.com/#{link.permalink}"
                        title: link.title
                        url: link.url

            error: =>

                @_error 'Error loading subreddit.'

            complete: (xhr) =>

                @_loading = false

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

            link = node.find('.fullsize')
            link.attr 'href', data.url
            link.append image

            node.insertBefore @_loadingNode
            @_imageYPos.push Math.floor $(image).position().top - @_imageOffset

        image.src = data.url

    _setupInfiniteScroll: ->

        @_loadingNode = $('<div class="loading"></div>')
        @_container.append @_loadingNode

        $(window).scroll =>

            return if @_loading

            spaceLeft = $(document).height() - $(document).scrollTop()
            return if spaceLeft > @_loadThreshold

            @_loadUrls()

    _setupIndexAutoUpdate: ->

        $(window).scroll =>

            if window.scrollY > @_imageYPos[@_showIndex + 1]
                @_showIndex += 1

            else if window.scrollY < @_imageYPos[@_showIndex]
                @_showIndex -= 1

