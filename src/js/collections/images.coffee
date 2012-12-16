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

        positions: ->

            @map (model) -> model.scrollY()

        comparator: (model) ->

            model.get 'position'
