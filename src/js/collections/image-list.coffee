define [

    'lib/backbone'
    'models/image'
    'constants'
    
], (Backbone, Image, Const) ->

    Backbone.Collection.extend

        url: "#{Const.baseURL}/r/aww.json?jsonp=?"
        model: Image

        initialize: ->

            @bind 'remove', (model) -> @remove model

        parse: (response) ->

            response.data.children
