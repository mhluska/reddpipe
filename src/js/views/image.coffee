define [
    
    'lib/backbone'
    'text!templates/image.html'

], (Backbone, imageTemplate) ->

    Backbone.View.extend

        initialize: ->

            console.log imageTemplate

        template: imageTemplate
