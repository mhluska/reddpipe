define [

    'lib/zepto'
    'lib/backbone'
    'views/image'
    'collections/image-list'
    
], ($, Backbone, ImageView, ImageList) ->

    View = Backbone.View.extend

        el: $('#pipeline')

        initialize: ->

            # TODO: Don't do this on pageload but bootstrap the initial models
            # on page load? According to the Backbone docs.
            @imageList = new ImageList()
            @imageList.bind 'add', @addImageView, @

            @imageList.fetch
                add: true
                type: 'GET'
                dataType: 'jsonp'
                data:
                    $.param
                        limit: 25
                        count: 25

        addImageView: (model) ->

            model.parseURL =>
                view = new ImageView model: model
                @$el.append view.render().el

    new View
