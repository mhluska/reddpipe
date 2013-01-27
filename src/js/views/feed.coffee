'use strict'

define [

    'lib/zepto'
    'lib/backbone'
    'views/image'
    'models/feed'
    'utils'
    'text!templates/message.html'

], ($, Backbone, ImageView, ImageModel, FeedModel, Utils, messageTemplate) ->

    Backbone.View.extend

        el: $('#pipeline')

        initialize: ->

            noneHTML = _.template messageTemplate,
                message: "There's nothing here!"
            endHTML = _.template messageTemplate,
                message: "We've hit the end!"
            @endNode = $(endHTML)

            @feedModel = new FeedModel @options.subreddit
            @feedModel.get('imageModels').on 'add', @addImageView, @
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

            @$el.append @endNode if @feedModel.get 'loadedAll'

        keydown: (event) ->
            # If we are typing into a text box, do not use hotkeys. But if we
            # are paging, blur the text box.
            if event.target.tagName is 'INPUT'
                if Utils.keyPressed event.which, 'pageUp', 'pageDown'
                    @feedModel.get('selectedURLBox')?.blur()
                else return

            # Don't mess with events when shift/ctrl and arrows/paging are
            # involved (overrides browser functionality).
            if Utils.keyPressed event.which, 'pageUp', 'pageDown', 'left', \
                    'right'

                return if event.shiftKey or event.ctrlKey or event.metaKey

            # Set up image navigation using arrows and page up/down.
            if Utils.keyPressed event.which, 'pageUp', 'left', 'a'

                event.preventDefault()

                viewingIndex = @feedModel.get('viewingIndex')
                if viewingIndex >= 1
                    if @imageViews[viewingIndex].minimize()
                        @imageViews[viewingIndex - 1].maximize()

                @feedModel.showPrev()

            else if Utils.keyPressed event.which, 'pageDown', 'right', 'd'

                event.preventDefault()

                viewingIndex = @feedModel.get('viewingIndex')
                unless viewingIndex is -1
                    if @imageViews[viewingIndex]?.minimize()
                        @imageViews[viewingIndex + 1]?.maximize()

                @feedModel.showNext()

            else if Utils.keyPressed event.which, 'v'

                event.preventDefault()
                @selectURL()

        selectURL: ->

            viewingIndex = @feedModel.get('viewingIndex')

            # If we're at the top of the page, use the first image for
            # convenience.
            viewingIndex = 0 if viewingIndex < 0
            @feedModel.set 'viewingIndex', viewingIndex

            selectedURLBox = @imageViews[viewingIndex].selectURL()
            @feedModel.set 'selectedURLBox', selectedURLBox

