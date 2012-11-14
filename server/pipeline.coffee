express = require 'express'

app = express()
app.set 'view engine', 'jade'
app.use express.static __dirname + '/public'

app.get '/', (req, res) ->

    res.render 'pipeline'

app.listen 7001
