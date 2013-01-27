# Finds the top image for a given subreddit in the past 24 hours.
# Iterates through entries for Redis key 'hits'. Also detects invalid subreddit
# entries and removes them from the database.

redis   = require('redis')
request = require('request')
config  = require('../config')
Utils   = require('../utils')
Const   = require('../constants')

# Finds the top image for a page of entries. The after parameter tells the
# Reddit API to load a chunk of listings after the given listing ID.
pageTop = (subreddit, after, maxScore, callback) ->
    options =
        json: true
        url: "#{Const.baseURL}/r/#{subreddit}.json"
        qs:
            after: after
            limit: 100

    request.get(options, (error, response, body) ->
        return callback(false) unless body.data

        now = new Date().getTime() / 1000
        yesterday = now - (24 * 60 * 60 * 1000)

        maxImage = null
        after = body.data.after
        entries = body.data.children

        # Keep paging through results until the image UTC is further than a
        # day back.
        for listing in entries when listing.data.created_utc > yesterday

            # Skip the entry if it does not have an image URL.
            # TODO: Checking the extension is a naive way to find images.
            # Sometimes an image might be extractable from a RESTful route.
            # Share a common module between client-side and server-side that
            # will do this. The client side already does this in a limited way.
            continue unless Utils.endsWithImage(listing.data.url)

            if listing.data.score > maxScore
                maxScore = listing.data.score
                maxImage = listing

        callback(maxImage, after, maxScore)
    )

top = (subreddit, callback) ->
    Utils.validateSubreddit(subreddit, (valid) ->
        return callback(false) unless valid

        maxImage = null
        pageTopCallback = (pageMaxImage, after, maxScore) ->
            # If no valid image was found on the current page, then we can
            # return early since the next page will surely not have an earlier
            # image.
            return callback(maxImage) unless pageMaxImage

            # If there are listings left to explore, do it.
            if after
                maxImage = pageMaxImage
                pageTop(subreddit, after, maxScore, pageTopCallback)
            else
                return callback(pageMaxImage)

        pageTop(subreddit, null, -Infinity, pageTopCallback)
    )


client = redis.createClient(config.redisPort)
client.hgetall('hits', (error, hits) ->
    subreddits = Object.keys(hits)
    do run = ->

        subreddit = subreddits.pop()
        return client.quit() unless subreddit

        top(subreddit, (maxImage) ->
            return unless maxImage?

            if maxImage is false
                console.log("#{subreddit} is invalid")
                client.hdel('hits', subreddit)
            else
                console.log(maxImage)
                client.hset('topimage', subreddit, JSON.stringify(maxImage))
        )

        # We limit our actions by 2 second intervals to prevent spamming the
        # RedditAPI.
        setTimeout(run, 2000)
)
