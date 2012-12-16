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

        keydown: (event) ->

            # Set up image navigation using arrows and page up/down.
            if event.which in
                    [Const.key.pageUp, Const.key.left, Const.key.a]

                event.preventDefault()
                @model.showPrev()

            else if event.which in
                    [Const.key.pageDown, Const.key.right, Const.key.d]

                event.preventDefault()
                @model.showNext()
