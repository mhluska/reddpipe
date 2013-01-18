express = require 'express'

app = express()

app.use express.bodyParser()
app.use (req, res, next) ->
    res.locals.basePath = req.headers['x-script-name'] or ''
    next()

require('./routes') app

app.set 'view engine', 'jade'
app.use express.static "#{__dirname}/public"

app.listen 7003
