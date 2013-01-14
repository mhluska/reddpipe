'use strict'

define [
    
    'lib/zepto'
    'lib/backbone'

], ($, Backbone) ->

    Backbone.View.extend

        el: $('#header')

        events:

            'keydown .search .subreddit': (event) -> event.stopPropagation()
            'click   .search input[type="submit"]': 'search'

        search: (event) ->

            event.preventDefault()

            form = $(event.target.form)
            subreddit = form.find('.subreddit').val()

            return unless subreddit

            window.location = "#{basePath}/r/#{subreddit}"
