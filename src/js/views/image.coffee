'use strict'

define [
    
    'lib/underscore'
    'lib/backbone'
    'collections/thumbs'
    'views/thumb'
    'constants'
    'text!templates/image.html'

], (_, Backbone, Thumbs, ThumbView, Const, imageTemplate) ->

    Backbone.View.extend

        className: 'row image'

        template: _.template imageTemplate

        events:

            'click   .more a': 'loadThumbs'
            'click   .urlBox': (event) -> event.target.select()

        initialize: (options) ->

            @imageModel = options.model

            thumbs = @imageModel.get 'thumbs'
            thumbs.on 'add', @addThumbView, @

        render: ->

            @$el.html @template @imageModel.toJSON()

            @

        loadThumbs: (event) ->

            event.preventDefault()

            button = $(event.target)
            loader = @$('.more .loading')
            loading = loader.css('display') isnt 'none'
            return if button.hasClass('disabled') or loading

            loader.show()

            # TODO: Temporary hack. Thumbs should be a view?
            @thumbsView = $('<div class="thumbs row"></div>')
            @thumbsView.insertAfter @$el.closest('.image.row')

            thumbs = @imageModel.get 'thumbs'
            thumbs.url = event.target.href
            thumbs.fetch

                update: true
                success: (collection, data) =>

                    button.addClass 'disabled'

                    data = data.guess
                    return unless data

                    # TODO: Temporary hack. data.guess should be stored in a
                    # Thumbs model.
                    @thumbsView.prepend \
                        "<h3><a href='#{data.href}' target='_blank'> \
                        #{data.text}</a></h3>"

                complete: -> loader.hide()

        addThumbView: (model) ->

            elem = new ThumbView(model: model).render().el
            @thumbsView.append elem

            $(elem).find('img').bind 'load', =>

                allThumbs = @thumbsView.find 'img'
                completed = allThumbs.filter -> @complete

                return unless completed.length is allThumbs.length
                return if @model.get 'thumbsProcessed'

                # Set the height of all the elements to be the the smallest
                # element's height.
                heights = $.map @thumbsView.find('img'), (elem) ->
                    $(elem).attr 'naturalHeight'

                @thumbsView.find('img').height Math.min.apply null, heights

                # Adjust the stored DOM node positions.
                for view in @options.imageViews
                    view.model.set 'position', view.$el.offset().top

                allThumbs.last().get(0).scrollIntoView false
                window.scroll 0, window.scrollY + Const.scrollTopPadding
                
                @imageModel.set 'thumbsProcessed', true

        selectURL: ->

            urlBoxElem = @el.querySelector('.urlBox')
            urlBoxElem.scrollIntoView()
            window.scroll 0, window.scrollY - Const.scrollTopPadding
            urlBoxElem.select()
            urlBoxElem
