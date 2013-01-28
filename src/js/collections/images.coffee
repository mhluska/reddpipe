'use strict'

define [

    'lib/backbone'
    'models/image'

], (Backbone, Image) ->

    Backbone.Collection.extend

        model: Image

        parse: (response) ->

            response.data.children

        # TODO: Cache this result if it becomes a performance issue.
        positions: ->

            @map (model) -> model.scrollY()

        addPositionY: (amount) ->
            @map((model) ->
                model.set('position', model.get('position') + amount)
            )
