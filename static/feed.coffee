class window.Feed

    constructor: (container, @subreddit = 'aww') ->

        @_resetImageIndices()
        @_resetPagination()

        @_container = $(container)
        @_containerWidth = @_container.width()
        @_loadThreshold = 1000
        @_imageOffset = 20

        # A callback to execute if the feed encounters an error.
        @_error = null

        @_container.addClass 'feed'
        @_setupInfiniteScroll()
        @_setupIndexAutoUpdate()

    setSubreddit: (@subreddit) ->

        # Alphanumeric characters only.
        return @_error?() unless /^[a-z0-9]+$/i.test subreddit

        @_resetImageIndices()
        @_resetPagination()
        @_container
            .html('')
            .append @_loadingNode

        @_loadUrls()

    error: (callback) ->
        
        @_error = callback

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

                for link in data.data.children

                    data = link.data

                    continue unless Utils.isImageUrl data.url

                    @_addImage
                        link: "http://reddit.com/#{data.permalink}"
                        title: data.title
                        url: data.url

            error: =>

                @_error?()

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

            node.prepend image
            node.insertBefore @_loadingNode
            @_imageYPos.push Math.floor $(image).position().top - @_imageOffset

        image.src = data.url

    _setupInfiniteScroll: ->

        @_loadingNode = $('<div class="loading">loading</div>')
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

