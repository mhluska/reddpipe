define [

    'lib/backbone'
    'models/image'
    'constants'
    
], (Backbone, Image, Const) ->

    Backbone.Collection.extend

        model: Image

        url: -> "#{Const.baseURL}/r/#{@feed.get 'subreddit'}.json?jsonp=?"

        initialize: (@feed) ->

            @bind 'remove', (model) -> @remove model

        parse: (response) ->

            @feed.set 'after', response.data.after
            response.data.children
