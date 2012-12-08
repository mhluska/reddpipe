define [

    'lib/backbone'
    'models/image'
    
], (Backbone, Image) ->

    Backbone.Collection.extend

        model: Image
