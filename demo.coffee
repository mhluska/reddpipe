field = $('.subreddit-field')

feed = new Feed document.getElementById 'feed'
feed.error ->

    field.addClass 'error'

$('.get-pictures').click ->

    field.removeClass 'error'
    feed.setSubreddit field.val()

feed.loadUrls()
