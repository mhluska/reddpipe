feed = new Feed document.getElementById 'feed'

$('.get-pictures').click ->

    feed.setSubreddit $('.subreddit-field').val()
    feed.clear()
    feed.loadUrls()

feed.loadUrls()
