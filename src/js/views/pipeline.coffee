define [

    'lib/backbone'
    'models/image'
    'views/image'
    
], (Backbone, ImageModel, ImageView) ->

    View = Backbone.View.extend

        el: $('#pipeline')

        initialize: ->

            imageView = new ImageView model: new ImageModel()

        render: ->

    new View
