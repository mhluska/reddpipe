'use strict'

define [
    
    'lib/backbone'
    'text!templates/thumb.html'

], (Backbone, thumbTemplate) ->

    Backbone.View.extend

        template: _.template thumbTemplate

        render: ->

            @el = @template @model.toJSON()

            @
