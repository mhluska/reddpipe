fs = require 'fs'
redis = require 'redis'
request = require 'request'

Utils = require '../utils'
Const = require '../constants'

module.exports = (app) ->

    sortHits = (hits) ->

        # TODO: Do this in Redis using a list.
        hits = ([key, parseInt value] for own  key, value of hits)
        hits.sort (a, b) -> if a[1] > b[1] then -1 else 1
        hits.splice(10)
        hits

    render = (req, res) ->

        client = redis.createClient()
        subreddit = req.params.subreddit

        # Validate subreddit. If valid, increment count in Redis otherwise
        # redirect to no such subreddit page.
        url = "#{Const.baseURL}/r/#{subreddit}.json"
        options =
            followRedirect: false
            url: url

        request.head options, (error, response, body) ->

            if error or response.statusCode isnt 200
                res.status 400
                return res.render '400', subreddit: subreddit

            client.hgetall 'hits', (error, hits) ->

                # Only allow a counter increment for the client's IP for a
                # subreddit every timeout seconds.
                timeout = 10
                hash = req.connection.remoteAddress + req.params.subreddit
                client.ttl hash, (error, time) ->

                    if time > 0
                        return res.render 'pipeline', hits: sortHits hits
                    else
                        client.set hash, 'ratelimit'
                        client.expire hash, timeout

                    client.hincrby 'hits', subreddit, 1
                    client.save()
                    client.end()
                    hits[subreddit] ?= 0
                    hits[subreddit] = parseInt(hits[subreddit]) + 1

                    res.render 'pipeline', hits: sortHits hits

    app.get '/', (req, res) -> res.redirect '/r/aww'
    app.get '/r/:subreddit', render
    app.get '/r/:subreddit/images/:count', render

    # Load all other routes in the directory.
    fs.readdirSync(__dirname).forEach (file) ->

        return unless Utils.endsWith file, '.js'
        return if file is 'index.js'

        name = file.substr 0, file.indexOf '.'
        require("./#{name}")(app)
