class window.Feed

    constructor: (container) ->

        @_loader = new Loader
        @_container = $(container)
        @_containerWidth = 600
        @_loadThreshold = 1000

        @_container.attr 'id', 'feed'
        @_container.width @_containerWidth

        @_setupInfiniteScroll()

    loadUrls: ->

        @_loading = true
        @_loader.loadUrls (urls) =>

            @_addImages urls
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

        $(document).scroll =>

            return if @_loading

            spaceLeft = $(document).height() - $(document).scrollTop()
            return if spaceLeft > @_loadThreshold

            @loadUrls()
