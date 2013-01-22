'use strict'

define [
    
    'lib/backbone'
    'text!templates/maximized.html'

], (Backbone, maximizedTemplate) ->

    Backbone.View.extend

        className: 'maximized'

        events: 'click .maximized': 'minimize'

        template: _.template maximizedTemplate

        render: ->

            @$el.html @template @model.toJSON()

            @

        minimize: ->

            @model.set('maximized', false)
            @$el.remove()
