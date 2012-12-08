updateHits = (subreddit) ->

    name = subreddit
    elem = ($('.count-tag span').filter -> $(@).prev().text() is name)[0]

    if elem
        val = parseInt($(elem).text()) + 1
        $(elem).text val

    $.ajax
        type: 'PUT'
        url: "#{appRoot}/subreddit/update"
        data: name: subreddit
        error: -> $(elem).text val

loadImages = (field, feed, update = true) ->

    subreddit = field.val()
    field.removeClass 'error'

    deferred = feed.setSubreddit subreddit

    deferred?.done ->

        updateHits(subreddit) if update

$ ->

    feed = new Feed $('#feed-wrap .feed')
    feed.error -> field.addClass 'error'

    field = $('.subreddit-field')

    $('.settings').submit do ->

        ready = true
        (event) ->

            event.preventDefault()

            return unless ready
            loadImages field, feed
            field.blur()

            ready = false
            setTimeout ( -> ready = true), 2000

    $(window).keydown (event) ->

        # Don't mess with events when shift/ctrl and arrows/paging are
        # involved (overrides browser functionality).
        if event.which in [33, 34, 37, 39]
            return if event.shiftKey or event.ctrlKey or event.metaKey

        # Set up image navigation using arrows and page up/down.
        if event.which in [33, 37, 65]

            event.preventDefault()
            feed.showPrev()

        else if event.which in [34, 39, 68]

            event.preventDefault()
            feed.showNext()

        # Set up image modal popup.
        else if event.which is 67

            return if event.ctrlKey or event.metaKey

            event.preventDefault()

            feed.overlayCaption = if event.shiftKey then true else false
            feed.toggleOverlay()

        # Select image URL.
        else if event.which is 86

            event.preventDefault()
            feed.selectURL()

    field.focus -> @select()

    # Animates the instructions area.
    $('.help').click do ->

        elem = $('.help').next()
        maxHeight = elem.height()
        elem.height(0)
        showing = false

        ->
            height = if showing then 0 else maxHeight
            elem.css 'height', height
            feed.feedOffset = height

            showing = !showing

    # Prevents hotkeys from taking effect while typing in the search box.
    field.keydown (event) -> event.stopPropagation()
            
    update = true
    unless field.val()
        update = false
        field.val 'aww'

    loadImages field, feed, update
