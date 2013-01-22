'use strict'

define [

    'lib/backbone'
    'collections/images'
    'constants'
    
], (Backbone, ImageModels, Const) ->

    # This model is a wrapper for the image collection. It holds meta data
    # about images.
    Backbone.Model.extend

        defaults:
            
            after: null
            loading: false
            loadedAll: false
            foundNone: false
            viewingIndex: -1

            # The currently selected URL input box in the feed. Used for
            # blurring when navigating with PageUp/PageDown.
            selectedURLBox: null

            topImageVotes: 0
            topImageData: null

        initialize: (subreddit) ->

            _.extend @, Backbone.Events

            @set 'subreddit', subreddit or Const.defaultSub
            @set 'imageModels', new ImageModels()

            # TODO: Temporary hack to bootstrap the topImageVotes number. Used
            # for collecting statistics about top images while I finish this
            # feature. There's also a race condition here between loading the
            # image data and finding a new image as the feed loads.
            ###
            $.ajax
                type: 'GET'
                url: '/topimage'
                data: subreddit: @get 'subreddit'
                success: (data) =>
                    topImage = $('.top.row img')
                    if data
                        @set 'topImageData', data
                        @set 'topImageVotes', data.votes
                        topImage.attr 'src', data.url
                        topImage.bind 'load', ->
                            $('.top.row .top-image-title').show()
                    else
                        topImage.attr 'src', 'http://placekitten.com/700/400'
            ###

            pending = new ImageModels()
            pending.url = "#{Const.baseURL}/r/#{@get 'subreddit'}.json?jsonp=?"
            pending.on 'ready', (model) => @get('imageModels').push model
            @set 'pending', pending

        loadItems: ->

            return if @get('loading') or @get 'loadedAll'

            @set 'loading', true

            # TODO: Don't do this on pageload but bootstrap the initial models
            # on page load? According to the Backbone docs.
            @get('pending').fetch
                update: true
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

            positions = @get('imageModels').positions()
            viewingIndex = @get 'viewingIndex'

            if window.scrollY is 0
                viewingIndex = -1

            else if window.scrollY is $(document).height() - $(window).height()
                viewingIndex = positions.length - 1

            # TODO: Get rid of this extra +/-1. It is there to work around a 1
            # pixel discrepancy between window.scrollY and positions[..] and
            # dev and production.
            if window.scrollY > positions[viewingIndex + 1] + 1
                viewingIndex += 1

            else if window.scrollY < positions[viewingIndex] - 1
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

            index = @get('viewingIndex')

            if index is @get('imageModels').length - 1
                $(window).scrollTop($(document).height())
                return

            @set('viewingIndex', index + 1)
            @focusActiveImage()

        focusActiveImage: ->

            @get('selectedURLBox')?.blur()

            if @get('viewingIndex') is -1
                window.scroll 0, 0
                return

            activeModel = @get('imageModels').at(@get('viewingIndex'))
            window.scroll 0, activeModel.scrollY()
