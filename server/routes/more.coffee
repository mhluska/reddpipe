jsdom = require 'jsdom'

module.exports = (app) ->

    app.get '/more', (req, res) ->

        # TODO: Check if Redis has a url -> (best guess, similar urls) mapping.
        # If yes, return that JSON, otherwise scrape the info from Google.
        more = null
        if more
            return res.json more

        imageUrl = req.query.url
        url = 'https://www.google.com/searchbyimage?&image_url=' + imageUrl

        jsdom.env
            html: url
            headers:
                'User-Agent': 'Mozilla/5.0 (X11; Linux i686) ' +
                    'AppleWebKit/537.11 (KHTML, like Gecko) ' +
                    'Chrome/23.0.1271.64 Safari/537.11'

            scripts: [ "http://code.jquery.com/jquery.js" ]
            features:
                FetchExternalResources: ['script']
                ProcessExternalResources: ['script']

            done: (errors, window) ->

                $ = window.$

                console.log $('#topstuff a').last().text()

                $('#iur img').parent().each (index, elem) ->

                    href = $(elem).attr 'href'
                    url = href.split('?')[1].split('&')[0].split('=')[1]
                    console.log url
