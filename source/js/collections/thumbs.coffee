'use strict'

define [

    'lib/backbone'
    'models/thumb'

], (Backbone, Thumb) ->

    Backbone.Collection.extend

        model: Thumb

        parse: (response) ->
            
            response.similar
