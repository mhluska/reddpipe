'use strict'

define [

    'lib/backbone'
    'views/header'
    'views/feed'
    
], (Backbone, HeaderView, FeedView) ->

    Backbone.Router.extend

        initialize: ->

            Backbone.history.start
                pushState: true
                root: basePath

        routes:

            'r/:subreddit': 'feed'

        feed: (subreddit) ->

            new HeaderView()
            feedView = new FeedView subreddit: subreddit
            feedView.render()
