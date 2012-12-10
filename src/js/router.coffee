'use strict'

define [

    'lib/backbone'
    'views/feed'
    
], (Backbone, FeedView) ->

    Backbone.Router.extend

        initialize: ->
            Backbone.history.start()

        routes:
            'r/:subreddit': 'feed'
            '*default': 'feed'

        feed: (subreddit) ->

            feedView = new FeedView
                subreddit: subreddit

            feedView.render()
