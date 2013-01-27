'use strict'

define [

    'lib/zepto'
    'lib/backbone'
    'models/image'

], ($, Backbone, ImageModel) ->

    Backbone.View.extend

        el: $('.top.row')

        events:

            'keydown .search .subreddit': (event) -> event.stopPropagation()
            'click   .search input[type="submit"]': 'search'

        initialize: ->
            topImage = new ImageModel(ImageModel::parse(app.topImage))
            url = 'http://placekitten.com/700/400'
            url = topImage.get('url') if topImage.get('url')
            @$('.feature').attr('src', url)

        search: (event) ->
            event.preventDefault()

            form = $(event.target.form)
            subreddit = form.find('.subreddit').val()

            return unless subreddit

            window.location = "#{app.basePath}/r/#{subreddit}"
