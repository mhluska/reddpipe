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
            imageLimit: Const.maxChunk
            viewingIndex: -1

        initialize: ->

            @set 'images', new Images()

            @bind 'change:subreddit', =>
                @get('images').url =
                    "#{Const.baseURL}/r/#{@get 'subreddit'}.json?jsonp=?"

            @set 'subreddit', 'aww'
            @get('images').bind 'sync', (images, response) =>
                @set 'after', response.data.after

        # TODO: Cache this result if it becomes a performance issue.
        positions: -> @get('images').positions()

        getNextImages: ->

            return if @get 'loading'
            return unless @get 'after'
            @getImages @get 'after'

        getImages: (after) ->

            return if @get 'loading'
            return if @get('imageLimit') < 1
            return if @get('images').length >= @get 'imageLimit'

            remaining = @get('imageLimit') - @get('images').length
            limit = Math.min Const.maxChunk, remaining

            @get('images').reset() unless after

            @set 'loading', true

            # TODO: Don't do this on pageload but bootstrap the initial models
            # on page load? According to the Backbone docs.
            @get('images').fetch
                update: true
                type: 'GET'
                dataType: 'jsonp'
                data: $.param
                    limit: limit
                    after: after

                success: (collection) =>

                    # Limit to one request every 2 seconds per API rules.
                    setTimeout =>

                        @set 'loading', false
                        @scroll()
                        @getNextImages()

                    , 2000

        scroll: ->

            positions = @positions()
            viewingIndex = @get 'viewingIndex'

            if window.scrollY is 0
                viewingIndex = -1

            else if window.scrollY is $(document).height() - $(window).height()
                viewingIndex = positions.length - 1

            if window.scrollY > positions[viewingIndex + 1]
                viewingIndex += 1

            else if window.scrollY < positions[viewingIndex]
                viewingIndex -= 1 unless viewingIndex is positions.length - 1

            @set 'viewingIndex', viewingIndex

            return if (positions.length - viewingIndex) > Const.loadThreshold
            return if @get 'loading'

            @set 'imageLimit', @get('imageLimit') + Const.maxChunk
            @getNextImages()

        showPrev: ->

            index = @get 'viewingIndex'

            return if index < 0

            @set 'viewingIndex', index - 1
            @focusActiveImage()

        showNext: ->

            index = @get 'viewingIndex'

            if index is @get('images').length - 1

                $(window).scrollTop $(document).height()
                return

            @set 'viewingIndex', index + 1
            @focusActiveImage()

        focusActiveImage: ->

            if @get('viewingIndex') is -1
                window.scroll 0, 0
                return

            activeModel = @get('images').at @get 'viewingIndex'
            window.scroll 0, activeModel.scrollY()
