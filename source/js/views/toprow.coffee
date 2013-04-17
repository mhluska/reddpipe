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
            # TODO: We probably want a specialized view here for the top image.
            topImage = new ImageModel(ImageModel::parse(app.topImage))
            @$('.feature').attr('src', topImage.get('url'))
            @$('.feature').parent().attr
                href:  topImage.get('url')
                title: topImage.get('title')

        search: (event) ->
            event.preventDefault()

            form = $(event.target.form)
            subreddit = form.find('.subreddit').val()

            return unless subreddit

            window.location = "#{app.basePath}/r/#{subreddit}"
