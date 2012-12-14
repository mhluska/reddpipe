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

            elem.find('img').bind 'load', =>
                @model.set 'position', @$el.position().top

            @$el.html elem

            @
