fs = require 'fs'
redis = require 'redis'
request = require 'request'

Utils = require '../utils'
Const = require '../constants'

module.exports = (app) ->

    # TODO: Is there a way to avoid this redirect flag? Does req or req store
    # that information?
    # TODO: Move all this logic to a controller and model.
    redirect = false
    client = redis.createClient()

    render = (req, res) ->
        
        subreddit = req.params.subreddit

        # Validate subreddit. If valid, increment count in Redis otherwise
        # redirect to no such subreddit page.
        url = "#{Const.baseURL}/r/#{subreddit}.json"
        options =
            followRedirect: false
            url: url

        request.head options, (error, response, body) ->

            if error or response.statusCode isnt 200
                redirect = true
                return res.redirect '/r/aww'

            client.hincrby 'hits', subreddit, 1 unless redirect
            client.hgetall 'hits', (error, hits) ->

                # TODO: Do this in Redis using a list.
                hits = ([key, parseInt value] for own  key, value of hits)
                hits.sort (a, b) -> if a[1] > b[1] then -1 else 1
                hits.splice(10)

                redirect = false
                res.render 'pipeline', hits: hits

    app.get '/', (req, res) ->
        redirect = true
        res.redirect '/r/aww'

    app.get '/r/:subreddit', render
    app.get '/r/:subreddit/images/:count', render

    # Load all other routes in the directory.
    fs.readdirSync(__dirname).forEach (file) ->

        return unless Utils.endsWith file, '.js'
        return if file is 'index.js'

        name = file.substr 0, file.indexOf '.'
        require("./#{name}")(app)
