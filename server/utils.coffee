request = require('request')
Const = require('./constants')

module.exports = class Utils

    @endsWith: (string, end) ->
        string.substr(-end.length) is end

    @endsWithImage: (string) ->
        extensions = ['gif', 'jpg', 'jpeg', 'png']
        for extension in extensions
            return true if @endsWith(string, extension)
        false

    # Asynchronously checks if the subreddit exists by sending a HEAD request to
    # reddit.com/r/subreddit-name.json.
    @validateSubreddit: (subreddit, callback) ->
        options =
            followRedirect: false
            url: "#{Const.baseURL}/r/#{subreddit}.json"

        request.head(options, (error, response, body) ->
            invalid = !!(error or response.statusCode isnt 200)
            if invalid then callback(false) else callback(true)
        )
