define [

    'lib/backbone'
    'models/image'
    'constants'
    
], (Backbone, Image, Const) ->

    Backbone.Collection.extend

        url: "#{Const.baseURL}/r/aww.json?jsonp=?"
        model: Image

        initialize: (@feed) ->

            @bind 'remove', (model) -> @remove model

        parse: (response) ->

            @feed.set 'after', response.data.after
            response.data.children
