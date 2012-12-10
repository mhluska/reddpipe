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

            @$el.html @template @model.toJSON()

            image = @$el.find 'img'
            image.bind 'load', =>
                @model.set 'position', image.position().top

            @
