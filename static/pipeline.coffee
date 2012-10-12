$ ->

    feed = new Feed $('#feed-wrap .feed')
    feed.error ->

        field.addClass 'error'

    field = $('.subreddit-field')

    autoLoad = false
    unless field.val()

        field.val 'aww'
        autoLoad = true

    $('.settings').submit (event) ->

        event.preventDefault()

        field.removeClass 'error'
        feed.setSubreddit field.val(), autoLoad
    
    .trigger 'submit'

    # Set up image navigation using arrows and page up/down.
    $(window).keydown (event) ->

        if event.which in [33, 37]

            event.preventDefault()
            feed.showPrev()

        else if event.which in [34, 39]

            event.preventDefault()
            feed.showNext()
            
