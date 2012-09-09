class window.Feed

    constructor: (container) ->

        @_container = $(container)
        @_containerWidth = 600

        @_container.attr 'id', 'feed'
        @_container.width @_containerWidth

    addImage: (url) ->

        image = $("<img src='#{url}' />")
        image.load =>

            return if image.width < @_containerWidth

            image.width @_containerWidth
            @_container.append image
