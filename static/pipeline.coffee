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

        event.preventDefault() if event.which in [33, 34]

        switch event.which

            when 33 then feed.showPrev()
            when 34 then feed.showNext()
