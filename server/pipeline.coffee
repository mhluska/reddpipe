express = require 'express'
app = express()

app.get '/', (req, res) ->

    res.send 'Reddit Pipeline'

app.listen 7001
