'use strict'

define [

    'lib/backbone'
    'views/feed'
    
], (Backbone, FeedView) ->

    Backbone.Router.extend

        initialize: ->
            Backbone.history.start()

        routes:
            'r/:subreddit':               'feed'
            'r/:subreddit/images/:count': 'feed'

            '*default': 'feed'

        feed: (subreddit, count) ->

            feedView = new FeedView
                subreddit: subreddit
                count: count

            feedView.render()
