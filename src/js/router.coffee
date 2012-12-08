'use strict'

define [

    'lib/backbone'
    'views/pipeline'
    
], (Backbone, pipeline) ->

    Backbone.Router.extend

        initialize: ->
            @pipeline = pipeline
            Backbone.history.start()

        routes:
            '': 'pipeline'

        pipeline: ->
            @pipeline.render()
