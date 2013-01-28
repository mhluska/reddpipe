'use strict'

define [

    'lib/backbone'
    'views/toprow'
    'views/header'
    'views/feed'

], (Backbone, TopRowView, HeaderView,FeedView) ->

    Backbone.Router.extend

        initialize: ->

            Backbone.history.start
                pushState: true
                root: app.basePath

        routes:

            'r/:subreddit': 'feed'

        feed: (subreddit) ->

            feedView = new FeedView subreddit: subreddit
            new HeaderView feedModel: feedView.model
            new TopRowView()

            feedView.render()
