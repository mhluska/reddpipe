fs = require 'fs'
redis = require 'redis'
request = require 'request'
config = require '../config'

Utils = require '../utils'
Const = require '../constants'

sortHits = (hits) ->
    # TODO: Do this in Redis using a list.
    hits = ([key, parseInt value] for own  key, value of hits)
    hits.sort (a, b) -> if a[1] > b[1] then -1 else 1
    hits.splice(20)
    hits

render = (req, res) ->
    client = redis.createClient config.redisPort
    subreddit = req.params.subreddit

    # Validate subreddit. If valid, increment count in Redis otherwise redirect
    # to no such subreddit page.
    Utils.validateSubreddit(subreddit, (valid) ->
        unless valid
            res.status 400
            res.render '400', subreddit: subreddit
            return

        client.hgetall('hits', (error, hits) ->
            client.hget('topimage', subreddit, (error, topImage) ->
                topImage ?= 'null'
                context =
                    hits: sortHits hits
                    topImage: topImage

                # Only allow a counter increment for the client's IP for a
                # subreddit every timeout seconds.
                # TODO: Factor this out so the /image/save route can use it as
                # well.
                timeout = 10
                hash = req.connection.remoteAddress + req.params.subreddit
                client.ttl(hash, (error, time) ->

                    if time > 0
                        res.render 'pipeline', context
                        return
                    else
                        client.set hash, 'ratelimit'
                        client.expire hash, timeout

                    client.hincrby 'hits', subreddit, 1
                    client.end()

                    hits ?= {}
                    hits[subreddit] ?= 0
                    hits[subreddit] = parseInt(hits[subreddit]) + 1

                    res.render 'pipeline', context
                )
            )
        )
    )

module.exports = (app) ->
    app.get '/', (req, res) ->
        res.redirect res.locals.basePath + '/r/aww'

    app.get '/r/:subreddit', render

    # Load all other routes in the directory.
    fs.readdirSync(__dirname).forEach (file) ->
        return unless Utils.endsWith file, '.js'
        return if file is 'index.js'

        name = file.substr 0, file.indexOf '.'
        require("./#{name}")(app)
