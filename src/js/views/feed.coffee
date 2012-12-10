'use strict'

define [

    'lib/zepto'
    'lib/backbone'
    'views/image'
    'models/feed'
    
], ($, Backbone, ImageView, Feed) ->

    Backbone.View.extend

        el: $('#pipeline')

        initialize: ->

            @model = new Feed()

            for own option, value of @options
                @model.set option, value if value

            # TODO: Don't do this on pageload but bootstrap the initial models
            # on page load? According to the Backbone docs.
            @model.get('images').bind 'add', @addImageView, @
            @model.get('images').bind 'reset', => @$el.html ''

        render: ->

            @model.getImages()

        addImageView: (model) ->

            # We append a placeholder div. If the model configures properly, we
            # replace it with the model view. Otherwise, we delete the
            # placeholder.
            empty = $(document.createElement 'div').appendTo @$el
            model.bind 'remove', -> empty.remove()

            model.parseURL =>

                view = new ImageView(model: model).render().el
                empty.replaceWith view
