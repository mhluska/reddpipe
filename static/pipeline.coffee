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
