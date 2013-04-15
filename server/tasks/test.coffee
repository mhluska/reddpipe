request = require('request')
magick  = require('imagemagick')

options =
    url: 'http://placekitten.com/340/480'
    encoding: 'binary'

request.get(options, (error, response) ->
    type = response.headers['content-type'].split('/').pop()
    magick.identify({ data: response.body }, (imageError, imageData) ->
        console.log(type)
        console.log(imageData.width)
    )
)
