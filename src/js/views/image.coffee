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

            'keydown input[type="text"]': (event) -> event.stopPropagation()

        initialize: ->

            # @model.bind 'change', @render, @

        render: ->

            elem = $(@template @model.toJSON())

            @$el.html elem

            @
