class window.ListingView extends Backbone.View
  className: 'listing'

  events:
    'mouseover': '_activateCaption'
    'mouseout':  '_deactivateCaption'
    'click img': '_mobileToggleCaption'

  template: _.template(
    '<figure>' +
      '<a href="<%= url %>" target="_blank"><img src="<%= url %>" /></a>' +
      '<figcaption>' +
        '<span class="votes" title="<%= ups %> up – <%= downs %> down"><%= score %></span>' +
        '<div>' +
          '<h2 class="title"><%= title %></h2>' +
          '<ul>' +
            '<li><a href="http://reddit.com<%= permalink %>" target="_blank"><%= subreddit %></a></li>' +
            '<li><a class="raw-image" href="<%= url %>" target="_blank">raw image</a></li>' +
          '</ul>' +
        '</div>' +
      '</figcaption>' +
    '</figure>'
  )

  initialize: ->
    @_mobileCaptionTimeoutID = null

    @model.on('destroy', @remove.bind(@))
    $(window).scroll(@_positionCaption.bind(@)) unless isMobile()

  render: ->
    @$el.html(@template(@model.attributes))

    if isMobile()
      @$el.find('.raw-image').show()
      @$el.find('img').parent().attr('href', 'javascript:void(0)')

    @_captionElem = @$el.find('figcaption')

    @

  # Returns the top position of the view's element. It has Math.floor applied so
  # that paging calculations in the feed view are simpler.
  top: -> Math.floor(@$el.position().top)

  # Returns the bottom position of the view's element.
  bottom: -> Math.floor(@top() + @$el.height())

  # Handles showing/hiding the caption on mobile devices. We rely on manually
  # setting the opacity since CSS doesn't handle tap event.
  _mobileToggleCaption: (event) ->
    return unless isMobile()

    if @model.get('active')
      @model.set('active', false)
      @_captionElem.css('opacity', 0)
      clearTimeout(@_mobileCaptionTimeoutID)
    else
      @model.set('active', true)
      @_captionElem.css('opacity', 1)
      @_mobileCaptionTimeoutID = setTimeout(@_mobileToggleCaption.bind(@, event), 6000)

  _activateCaption: (event) ->
    @model.set('active', true)
    @_positionCaption(event)

  _deactivateCaption: -> @model.set('active', false)

  _setCaptionCSS: (position, top, bottom, left) ->
    @_captionElem.css(
      position: position
      top: top
      bottom: bottom
      left: left
    )

  # Moves the caption based on image position in the viewport. Without this
  # function, the caption just shows/hides at the top of the image via CSS.
  _positionCaption: (event) ->
    return unless @model.get('active')

    image = @$el.find('img')
    imagePadding = image.position().left
    offset = $(window).scrollTop() - image.offset().top

    # Keep the caption width in sync with the image regardless of window resize.
    @_captionElem.css('width', image.width())

    # If the image is completely visible, we can reset caption positioning to
    # defaults and exit.
    if offset <= 0
      return @_setCaptionCSS('absolute', imagePadding, 'auto', imagePadding)

    imageOffsetBottom = image.offset().top + image.outerHeight()
    imageVisiblePortion = imageOffsetBottom - $(window).scrollTop()
    captionOverflowingBottom = imageVisiblePortion < @_captionElem.outerHeight()

    # Now the image if partially hidden and there isn't enough room for the
    # caption, so just glue the caption to the bottom of the image.
    if captionOverflowingBottom
      return @_setCaptionCSS('absolute', 'auto', imagePadding, imagePadding)

    # Now the image is partially hidden but there is room for a caption. So fix
    # it to the top of the viewport.
    @_setCaptionCSS('fixed', 0, 'auto', image.offset().left)
