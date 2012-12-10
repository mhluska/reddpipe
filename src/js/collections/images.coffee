define [

    'lib/backbone'
    'models/image'
    
], (Backbone, Image) ->

    Backbone.Collection.extend

        model: Image

        initialize: ->

            @bind 'remove', (model) -> @remove model

        parse: (response) ->

            response.data.children
