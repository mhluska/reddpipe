$ ->

    field = $('.subreddit-field')

    feed = new Feed $('#feed-wrap .feed')
    feed.error ->

        field.addClass 'error'

    $('.settings').submit (event) ->

        event.preventDefault()

        field.removeClass 'error'
        feed.setSubreddit field.val()

    .trigger 'submit'

    $(window).keydown (event) ->

        if event.which in [33, 37]

            event.preventDefault()
            feed.showPrev()

        else if event.which in [34, 39]

            event.preventDefault()
            feed.showNext()
