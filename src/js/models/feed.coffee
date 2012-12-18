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
            loadedAll: false
            foundNone: false
            viewingIndex: -1
            after: null

        initialize: (subreddit) ->

            _.extend @, Backbone.Events

            @set 'subreddit', subreddit or Const.defaultSub
            @set 'images', new Images()
            
            pending = new Images()
            pending.url = "#{Const.baseURL}/r/#{@get 'subreddit'}.json?jsonp=?"
            pending.on 'ready', (model) => @get('images').push model
            @set 'pending', pending

        loadItems: ->

            return if @get('loading') or @get 'loadedAll'

            @set 'loading', true

            # TODO: Don't do this on pageload but bootstrap the initial models
            # on page load? According to the Backbone docs.
            @get('pending').fetch
                update: true
                type: 'GET'
                dataType: 'jsonp'
                data: $.param
                    limit: Const.maxChunk
                    after: @get 'after'

                success: (collection, data) =>

                    unless data.data.after
                        if collection.length
                            @set 'loadedAll', true
                        else
                            @set 'foundNone', true
                        return

                    @set 'after', data.data.after
                    setTimeout =>

                        # Trigger scroll in case we reached the bottom before
                        # reallowing loads.
                        @scroll()
                        @set 'loading', false

                    , Const.APIRateLimit

        scroll: ->

            positions = @get('images').positions()
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
            return if @get('loading') or @get('loadedAll')

            @loadItems()

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
