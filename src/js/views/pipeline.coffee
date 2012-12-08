define [

    'lib/backbone'
    'models/pipeline'
    
], (Backbone, Pipeline) ->

    View = Backbone.View.extend

        model: new Pipeline()

        initialize: ->

        render: ->

    new View
