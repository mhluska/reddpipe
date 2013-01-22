'use strict'

define [

    'lib/zepto'
    'lib/backbone'
    'views/image'
    'models/feed'
    'utils'
    'constants'
    'text!templates/message.html'
    
], ($, Backbone, ImageView, FeedModel, Utils, Const, messageTemplate) ->

    Backbone.View.extend

        el: $('#pipeline')

        initialize: ->

            noneHTML = _.template messageTemplate,
                message: "There's nothing here!"
            endHTML = _.template messageTemplate,
                message: "We've hit the end!"
            @endNode = $(endHTML)

            @feedModel = new FeedModel @options.subreddit
            @feedModel.get('images').on 'add', @addImageView, @
            @feedModel.on 'change:foundNone', => @$el.append noneHTML

            @imageViews = []

            $(window).scroll @feedModel.scroll.bind @feedModel
            $(window).keydown @keydown.bind @

        render: ->

            @$el.html ''
            @feedModel.loadItems()

            @

        addImageView: (imageModel) ->

            view = new ImageView
                imageViews: @imageViews
                model: imageModel

            @imageViews.push view
            elem = view.render().el

            # Replace the temporary img node with the model's in-memory
            # image.
            image = $(elem).find '.feature'
            attributes = Utils.DOMAttributes image
            newImage = $(imageModel.get('image'))
            newImage.attr attributes
            image.replaceWith newImage

            @$el.append elem
            imageModel.set
                position: $(elem).offset().top
                height:   $(elem).height()

            # TODO: This is a huge hack. Move this to ImageModel and avoid
            # restructuring the model on the fly. We really only want to save
            # the JSON data that came from Reddit, so maybe create a
            # RedditImageModel and wrap it in ImageModel which contains
            # additional app-specific data.
            votes = imageModel.get 'votes'
            wrapper = newImage.closest '.alpha'

            if newImage.width() is wrapper.width()
                if votes > @feedModel.get 'topImageVotes'
                    @feedModel.set 'topImageVotes', votes
                    copiedImageModel = imageModel.clone()
                    copiedImageModel.unset 'image'
                    copiedImageModel.set 'subreddit', @options.subreddit
                    copiedImageModel.set 'url', newImage.attr 'src'
                    copiedImageModel.url = '/topimage'
                    copiedImageModel.save()

            @$el.append @endNode if @feedModel.get 'loadedAll'

        keyPressed: (pressedCode, keys...) ->

            for keyAttr in keys
                return true if Const.key[keyAttr] is pressedCode
            false

        keydown: (event) ->

            # Don't mess with events when shift/ctrl and arrows/paging are
            # involved (overrides browser functionality).
            if @keyPressed event.which, 'pageUp', 'pageDown', 'left', 'right'

                return if event.shiftKey or event.ctrlKey or event.metaKey

            # Set up image navigation using arrows and page up/down.
            if @keyPressed event.which, 'pageUp', 'left', 'a'

                event.preventDefault()
                @feedModel.showPrev()

            else if @keyPressed event.which, 'pageDown', 'right', 'd'

                event.preventDefault()
                @feedModel.showNext()

            else if @keyPressed event.which, 'v'

                event.preventDefault()
                @$('.urlBox').get(@feedModel.get 'viewingIndex')?.select()
