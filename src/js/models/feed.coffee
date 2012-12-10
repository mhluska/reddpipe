'use strict'

define [

    'lib/backbone'
    'collections/images'
    'constants'
    
], (Backbone, Images, Const) ->

    # This model is a wrapper for the images collection. It holds meta
    # information about images.
    Backbone.Model.extend

        defaults:
            
            loading: false
            after: null
            count: Const.maxChunk
            viewingIndex: 0

        initialize: ->

            @set 'images', new Images()

            @bind 'change:count', => @set 'count', parseInt @get 'count'
            @bind 'change:subreddit', =>
                @get('images').url =
                    "#{Const.baseURL}/r/#{@get 'subreddit'}.json?jsonp=?"

            @set 'subreddit', 'aww'

            @get('images').bind 'sync', (images, response) =>
                @set 'after', response.data.after

        # TODO: Cache this result if it becomes a performance issue.
        positions: -> @get('images').positions()

        getNextImages: ->

            @getImages @get 'after'

        getImages: (after) ->

            return if @get('count') < 1
            return if @get('images').length >= @get('count')

            remaining = @get('count') - @get('images').length
            limit = Math.min Const.maxChunk, remaining

            @get('images').reset() unless after

            @set 'loading', true
            @get('images').fetch
                add: true
                type: 'GET'
                dataType: 'jsonp'
                data: $.param
                    limit: limit
                    after: after

                success: (collection) =>

                    @set 'loading', false

                    # Limit to one request every 2 seconds per API rules.
                    setTimeout ( => @getNextImages()), 2000
