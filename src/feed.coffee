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

                console.log data

                @_after = data.data.after

                for link in data.data.children

                    data = link.data

                    continue unless Utils.isImageUrl data.url

                    @_addImage
                        title: data.title
                        url: data.url

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

    _addImage: (data) ->

        template = $('#tmpl-image-wrap').text()
        node = $(Mustache.render template, data)

        image = new Image()
        $(image).load =>

            return if image.width < @_containerWidth

            image.width = @_containerWidth
            node.prepend image
            node.insertBefore @_loadingNode

        image.src = data.url

    _setupInfiniteScroll: ->

        @_loadingNode = $('<div class="loading">loading</div>')
        @_container.append @_loadingNode

        $(document).scroll =>

            return if @_loading

            spaceLeft = $(document).height() - $(document).scrollTop()
            return if spaceLeft > @_loadThreshold

            @_loadUrls()
