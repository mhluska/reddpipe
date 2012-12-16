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
            @model.set 'imageLimit', parseInt @options.count if @options.count

            @model.get('images').bind 'add', @addImageView, @
            @model.get('images').bind 'reset', => @$el.html ''

            $(window).scroll @model.scroll.bind @model
            $(window).keydown @keydown.bind @

        render: ->

            @model.getImages()

        addImageView: (model) ->

            model.parseURL =>

                view = new ImageView(model: model).render().el

                image = $(view).find 'img'
                image.bind 'load', =>

                    @$el.append view
                    model.set
                        'position': $(view).offset().top
                        'height':   $(view).height()

                    @model.get('images').sort()

        keyPressed: (pressedCode, keys...) ->

            for keyAttr in keys

                return true if Const.key[keyAttr] is pressedCode

            false

        keydown: (event) ->

            # Don't mess with events when shift/ctrl and arrows/paging are
            # involved (overrides browser functionality).
            if @keyPressed event.which, 'pageUp', 'pageDown', 'left', 'right'

                return if event.shiftKey or event.ctrlKey or event.metaKey

            # Set up image navigation using arrows and page up/down.
            if @keyPressed event.which, 'pageUp', 'left', 'a'

                event.preventDefault()
                @model.showPrev()

            else if @keyPressed event.which, 'pageDown', 'right', 'd'

                event.preventDefault()
                @model.showNext()

            else if @keyPressed event.which, 'v'

                event.preventDefault()
                @$('.urlBox').get(@model.get 'viewingIndex')?.select()
