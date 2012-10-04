class window.Feed

    constructor: (container, @subreddit = 'aww') ->

        @_resetPagination()

        @_container = $(container)
        @_containerWidth = @_container.width()
        @_loadThreshold = 1000
        @_imageOffset = 20

        # Used for navigating by images with page up/down.
        @_imageYPos = [0]
        @_showIndex = 0

        # A callback to execute if the feed encounters an error.
        @_error = null

        @_container.addClass 'feed'
        @_setupInfiniteScroll()

    showPrev: ->

        return if @_showIndex is 0

        if window.scrollY is (@_imageYPos[@_showIndex] - @_imageOffset)
            @_showIndex -= 1
        else
            @_showIndex = @_findShowIndex()

        @_showImage()

    showNext: ->

        return if @_showIndex >= @_imageYPos.length - 1

        if window.scrollY is (@_imageYPos[@_showIndex] - @_imageOffset)
            @_showIndex += 1
        else
            @_showIndex = @_findShowIndex() + 1

        @_showImage()

    _findShowIndex: ->

        return 0 if window.scrollY is 0

        for pos, index in @_imageYPos
            return index - 1 if window.scrollY <= pos

    _showImage: ->

        console.log "showing #{@_showIndex}"

        pos = @_imageYPos[@_showIndex]

        return unless pos?

        $(window).scrollTop pos - @_imageOffset

    setSubreddit: (@subreddit) ->

        # Alphanumeric characters only.
        return @_error?() unless /^[a-z0-9]+$/i.test subreddit

        @_resetPagination()
        @_container
            .html('')
            .append @_loadingNode

        @_loadUrls()

    error: (callback) ->
        
        @_error = callback

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

                console.log 'failing'
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
            @_imageYPos.push $(image).position().top

        image.src = data.url

    _setupInfiniteScroll: ->

        @_loadingNode = $('<div class="loading">loading</div>')
        @_container.append @_loadingNode

        $(document).scroll =>

            return if @_loading

            spaceLeft = $(document).height() - $(document).scrollTop()
            return if spaceLeft > @_loadThreshold

            @_loadUrls()
