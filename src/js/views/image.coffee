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

        initialize: ->

            # @model.bind 'change', @render, @

        render: ->

            elem = $(@template @model.toJSON())

            @options.thumb.className = 'scale-with-grid'
            elem.find('img').replaceWith @options.thumb

            @model.set 'position', $(@options.thumb).position().top
            @$el.html elem

            @
