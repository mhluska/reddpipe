'use strict'

define [

    'lib/backbone'
    'views/feed'
    
], (Backbone, FeedView) ->

    Backbone.Router.extend

        initialize: ->

            Backbone.history.start pushState: true

        routes:

            'r/:subreddit': 'feed'

        feed: (subreddit) ->

            feedView = new FeedView subreddit: subreddit
            feedView.render()
