redis = require 'redis'
config = require '../config'

module.exports = (app) ->

    client = redis.createClient config.redisPort

    app.get '/topimage', (req, res) ->
        # TODO: Reuse this in more.coffee.
        client.hget 'topImage', req.query.subreddit, (error, topImage) ->
            res.set 'Content-Type', 'application/json'
            res.send topImage

    app.post '/topimage', (req, res) ->
        client.hset 'topImage', req.body.subreddit, JSON.stringify req.body
