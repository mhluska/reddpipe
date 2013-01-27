'use strict'

define [

    'lib/backbone'
    'views/toprow'
    'views/feed'

], (Backbone, TopRowView, FeedView) ->

    Backbone.Router.extend

        initialize: ->

            Backbone.history.start
                pushState: true
                root: app.basePath

        routes:

            'r/:subreddit': 'feed'

        feed: (subreddit) ->

            new TopRowView()
            feedView = new FeedView subreddit: subreddit
            feedView.render()
