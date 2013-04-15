request = require('request')
magick  = require('imagemagick')
Const   = require('./constants')

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

    @getImageData: (url, callback) ->
        options =
            url: url
            encoding: 'binary'

        request.get(options, (error, response) =>
            return if error
            return unless @endsWithImage(response.headers['content-type'])
            console.log response.headers['content-type']

            magick.identify({ data: response.body }, (imageError, data) ->
                if imageError
                    console.error("Utils.getImageData: #{imageError}")
                    return

                callback(null, data.width)
            )
        )
