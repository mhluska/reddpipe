class window.FeedView extends Backbone.View
  initialize: (options) ->
    @collection = new ListingCollection()
    @_listingsElem = @$el.find('.listings')

    @_resetFeed()

    @listingCache = options.listingCache
    @listingCache.on('sync', => @_addPage() if @_listingsElem.is(':empty'))
    @listingCache.on('reset', @_resetFeed.bind(@))
    @collection.on('add', @render.bind(@))

    $(window).scroll(@_scrollHandler.bind(@))
    $(window).keydown(@_pagingHandler.bind(@))

    @listingCache.fetchSubreddits()

  render: (model) ->
    model?.resolveImage(@_resolveHandler.bind(@, model))

    @

  _resetFeed: ->
    @_listingsElem.empty()
    @_activeView = null
    @_listingViews = []

  _addPage: -> @collection.add(@listingCache.getPage())

  _resolveHandler: (model) ->
    view = new ListingView(model: model)
    @_listingViews.push(view)

    viewElem = $(view.render().el)
    image = viewElem.find('img')
    image.error -> model.destroy()

    # We append the image to the feed after it has loaded to prevent empty
    # image frames hanging around. We also cache the DOM position of the image
    # and a reference to the image element for image cycling in the
    # _pagingHandler.
    image.load =>
      @_listingsElem.append(viewElem)
      @_activeView ?= view

  _scrollHandler: (event) ->
    # Handle infinite scrolling.
    threshold = 1000
    scrolled = $(window).scrollTop() + $(window).height()
    @_addPage() if ($(document).height() - scrolled) < threshold

    # Handle updating the active image. It is the first image in the collection
    # with a bottom DOM position greater than the top of the viewport.
    @_updateActiveImage() unless isMobile()

  # TODO(maros): Throttling is probably premature optimization.
  _updateActiveImage: _.throttle((->
    scrollTop = $(window).scrollTop()

    # TODO(maros): Make this not linear.
    @_activeView = _.min(@_listingViews, (view) ->
      # TODO(maros): Sometimes bottom returns 0. I think this happens for images
      # that have been removed from the DOM but are still hanging around
      # _listingViews. Fix that.
      bottom = view.bottom()
      return unless bottom

      # We only care about the smallest positive distance from the viewport
      # top to the image bottom so ignore negative deltas.
      delta = bottom - scrollTop
      return delta if delta? and delta >= 0
    )
  ), 50)

  _pagingHandler: (event) ->
    # This handler concerns only page up and page down.
    return unless event.which in [FeedModel.keyUp, FeedModel.keyDown]

    # If the first image has not loaded yet, we don't have to do anything.
    return unless @_activeView

    # If we are paging up and we are on the first image, just scroll to top.
    activeTopImage = @_activeView.$el.is(@_listingsElem.children().first())
    return if event.which is FeedModel.keyUp and activeTopImage

    # If we are paging down and we are on the last image, just scroll down.
    activeBottomImage = @_activeView.$el.is(@_listingsElem.children().last())
    return if event.which is FeedModel.keyDown and activeBottomImage

    event.preventDefault()

    if event.which is FeedModel.keyUp
      overlapping = @_activeView.top() < $(window).scrollTop()
      newImage = if overlapping then @_activeView.$el else @_activeView.$el.prev()
    else
      aboveFirstImage = activeTopImage and @_activeView.top() > $(window).scrollTop()
      newImage = if aboveFirstImage then @_activeView.$el else @_activeView.$el.next()

    # If there is no previous or next image we can return.
    return unless newImage.length

    newImage.get(0).scrollIntoView()

    # TODO(maros): Make it so we don't have this linear search. _listingViews
    # will have to be ordered by DOM position and the .next() and .prev() stuff
    # above will be based on _listingViews.
    @_activeView = _.find(@_listingViews, (view) -> view.el is newImage)
