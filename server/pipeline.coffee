require 'express-namespace'
express = require 'express'

app = express()
require('./routes') app

app.set 'view engine', 'jade'
app.use express.static "#{__dirname}/public"

app.listen 7003
