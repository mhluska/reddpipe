'use strict'

define [

    'lib/zepto'
    'lib/backbone'

], ($, Backbone) ->

    Backbone.View.extend

        el: $('#header')

        events:
            'click #enable-hotkeys': 'toggleHotkeys'
            'click #configure-hotkeys': 'configureHotkeys'

        initialize: ->
            console.log @options

        toggleHotkeys: ->
            enabled = @options.feedModel.get('hotkeysEnabled')
            @options.feedModel.set('hotkeysEnabled', !enabled)

        configureHotkeys: ->
            area = @$('#configure-area')
            heightBefore = area.height()
            area.toggleClass('hidden')
            heightAfter = area.height()

            # Update the in-memory y-positions of images.
            delta = heightAfter - heightBefore
            @options.feedModel.get('imageModels').addPositionY(delta)
