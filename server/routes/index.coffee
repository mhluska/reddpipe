fs = require 'fs'
Utils = require '../utils'

module.exports = (app) ->

    render = (req, res) -> res.render 'pipeline'

    app.get '/', render
    app.get '/r/:subreddit', render
    app.get '/r/:subreddit/images/:count', render

    # Load all other routes in the directory.
    fs.readdirSync(__dirname).forEach (file) ->

        return unless Utils.endsWith file, '.js'
        return if file is 'index.js'

        name = file.substr 0, file.indexOf '.'
        require("./#{name}")(app)
