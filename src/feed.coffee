class window.Feed

    constructor: (@_loader, container) ->

        @_container = $(container)
        @_containerWidth = 600
        @_loadThreshold = 1000
        @_loading = false

        @_container.attr 'id', 'feed'
        @_container.width @_containerWidth

        @_setupInfiniteScroll()

    addImage: (url) ->

        image = $("<img src='#{url}' />")
        image.load =>

            return if image.width < @_containerWidth

            image.width @_containerWidth
            @_container.append image

    _setupInfiniteScroll: ->

        $(document).scroll =>

            return if @_loading

            spaceLeft = $(document).height() - $(document).scrollTop()
            return if spaceLeft > @_loadThreshold

            @_loading = true
            @_loader.loadUrls (urls) =>

                @addImage url for url in urls
                @_loading = false

