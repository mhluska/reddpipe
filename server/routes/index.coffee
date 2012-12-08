fs = require 'fs'
utils = require '../utils'

module.exports = (app) ->

    app.get '/', (req, res) ->
        res.render 'pipeline'

    # Load all other routes in the directory.
    fs.readdirSync(__dirname).forEach (file) ->

        return unless utils.endsWith file, '.js'
        return if file is 'index.js'

        name = file.substr 0, file.indexOf '.'
        require("./#{name}")(app)
