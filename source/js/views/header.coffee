'use strict'

define [

    'lib/zepto'
    'lib/backbone'

], ($, Backbone) ->

    Backbone.View.extend

        el: $('#header')

        events:
            'click #enable-hotkeys': 'toggleHotkeys'
            'click .brackets': 'configureHotkeys'

        toggleHotkeys: ->
            enabled = @options.feedModel.get('hotkeysEnabled')
            @options.feedModel.set('hotkeysEnabled', !enabled)

        configureHotkeys: ->
            area = @$('#configure-area-wrap')
            heightBefore = area.height()
            heightAfter = 0
            if heightBefore is 0
                heightAfter = area.get(0).scrollHeight

            area.animate { height: heightAfter },
                duration: 200
                easing: 'ease-out'
                complete: =>
                    # Update the in-memory y-positions of images.
                    delta = heightAfter - heightBefore
                    @options.feedModel.get('imageModels').addPositionY(delta)
