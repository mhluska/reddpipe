express = require 'express'

app = express()
app.locals.production = process.argv[2] is 'production'
require('./routes') app

app.set 'view engine', 'jade'
app.use express.static "#{__dirname}/public"

app.listen 7001
