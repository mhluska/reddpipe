$ ->

    field = $('.subreddit-field')

    feed = new Feed document.getElementById 'feed'
    feed.error ->

        field.addClass 'error'

    $('.get-pictures').submit (event) ->

        event.preventDefault()

        field.removeClass 'error'
        feed.setSubreddit field.val()

    .trigger 'submit'
