class window.Feed

    constructor: (container, @subreddit = 'aww') ->

        @_resetPagination()

        @_container = $(container)
        @_containerWidth = 500
        @_loadThreshold = 1000

        # A callback to execute if the feed encounters an error.
        @_error = null

        @_container.attr 'id', 'feed'
        @_container.width @_containerWidth

        @_setupInfiniteScroll()

    setSubreddit: (@subreddit) ->

        # Alphanumeric characters only.
        return @_error?() unless /^[a-z0-9]+$/i.test subreddit

        @_resetPagination()
        @_container.html ''
        @loadUrls()

    error: (callback) ->
        
        @_error = callback

    loadUrls: ->

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

                urls = (link.data.url for link in data.data.children)
                valid = (url for url in urls when Utils.isImageUrl url)

                @_addImages valid

            error: =>

                console.log 'failing'
                @_error?()

            complete: (xhr) =>

                console.log 'completing'
                console.log xhr.status
                @_loading = false

    _resetPagination: ->

        # Used to get more pages from the API call.
        @_count = 0
        @_after = null
        @_resultsPerPage = 25

    _addImages: (urls) ->

        @_container.append @_loadingNode
        @_addImage url for url in urls

    _addImage: (url) ->

        image = new Image()
        $(image).load =>

            if image.width < @_containerWidth
                console.log "removing #{url} #{image.width}"

            return if image.width < @_containerWidth

            image.width = @_containerWidth
            $(image).insertBefore @_loadingNode

        image.src = url

    _setupInfiniteScroll: ->

        @_loadingNode = $('<div class="loading">loading</div>')
        @_container.append @_loadingNode

        $(document).scroll =>

            return if @_loading

            spaceLeft = $(document).height() - $(document).scrollTop()
            return if spaceLeft > @_loadThreshold

            @loadUrls()
