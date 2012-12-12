'use strict'

define [

    'lib/zepto'
    'lib/backbone'
    'views/image'
    'models/feed'
    'constants'
    
], ($, Backbone, ImageView, Feed, Const) ->

    Backbone.View.extend

        el: $('#pipeline')

        initialize: ->

            @model = new Feed()

            @model.set 'subreddit', @options.subreddit if @options.subreddit
            @model.set 'count', parseInt @options.count if @options.count

            @model.get('images').bind 'add', @addImageView, @
            @model.get('images').bind 'reset', => @$el.html ''

            $(window).scroll @scroll.bind @

        render: ->

            @model.getImages()

        addImageView: (model) ->

            # We append a placeholder div. If the model configures properly, we
            # replace it with the model view. Otherwise, we delete the
            # placeholder.
            empty = $(document.createElement 'div').appendTo @$el
            model.bind 'remove', -> empty.remove()

            model.parseURL ->

                view = new ImageView(model: model, el: empty).render().el

        scroll: ->

            positions = @model.positions()
            viewingIndex = @model.get 'viewingIndex'

            if window.scrollY is 0
                viewingIndex = 0

            else if window.scrollY is $(document).height() - $(window).height()
                viewingIndex = positions.length - 1

            if window.scrollY > positions[viewingIndex + 1]
                viewingIndex += 1

            else if window.scrollY < positions[viewingIndex]
                viewingIndex -= 1

            @model.set 'viewingIndex', viewingIndex

            return if @model.get 'loading'
            return if (positions.length - viewingIndex) > Const.loadThreshold

            @model.set 'count', @model.get('count') + Const.maxChunk
            @model.getNextImages()
