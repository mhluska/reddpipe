'use strict'

define [
    
    'lib/underscore'
    'lib/backbone'
    'text!templates/image.html'

], (_, Backbone, imageTemplate) ->

    Backbone.View.extend

        tagName: 'div'

        className: 'image'

        template: _.template imageTemplate

        events:

            'click   .urlBox': (event) -> event.target.select()
            'keydown .urlBox': (event) -> event.stopPropagation()

        render: ->

            elem = $(@template @model.toJSON())

            @$el.html elem
            @
