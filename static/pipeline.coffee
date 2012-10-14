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

    $('.settings').submit (event) ->

        event.preventDefault()
        loadImages field, feed
    
    # Set up image navigation using arrows and page up/down.
    $(window).keydown (event) ->

        if event.which in [33, 37]

            event.preventDefault()
            feed.showPrev()

        else if event.which in [34, 39]

            event.preventDefault()
            feed.showNext()
            
    update = true
    unless field.val()
        update = false
        field.val 'aww'

    loadImages field, feed, update
