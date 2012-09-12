class window.Feed

    constructor: (container) ->

        @_loader = new Loader
        @_container = $(container)
        @_containerWidth = 500
        @_loadThreshold = 1000

        # A callback to execute if the feed encounters an error.
        @_error = null

        @_container.attr 'id', 'feed'
        @_container.width @_containerWidth

        @_setupInfiniteScroll()

    setSubreddit: (subreddit) ->

        # Alphanumeric characters only.
        return @_error?() unless /^[a-z0-9]+$/i.test subreddit

        @_loader = new Loader subreddit
        @clear()
        @loadUrls()

    error: (callback) ->
        
        @_error = callback

    clear: ->

        @_container.html ''

    loadUrls: ->

        @_loading = true

        deferred = @_loader.loadUrls (urls) =>

            @_addImages urls

        deferred.fail =>
            
            @_error?()

        deferred.always =>

            @_loading = false

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
