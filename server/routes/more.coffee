jsdom = require 'jsdom'
redis = require 'redis'
config = require '../config'

module.exports = (app) ->

    app.get '/more', (req, res) ->

        imageUrl = req.query.url
        url = 'https://www.google.com/searchbyimage?&image_url=' + imageUrl

        # Check if Redis has a url -> (best guess, similar urls) mapping. If
        # yes, return that JSON, otherwise scrape the info from Google.
        client = redis.createClient config.redisPort
        client.hget 'more', imageUrl, (error, result) ->

            if result
                res.set 'Content-Type', 'application/json'
                return res.send result

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

                    guess = null
                    if ~$('#topstuff > div').last().text().indexOf 'Best guess'
                        elem = $('#topstuff a').last()
                        guess =
                            text: elem.text()
                            href: window.location.protocol + '/' +
                                  window.location.hostname + elem.attr 'href'

                    similarThumbs = $.map $('#iur img').parent(), (elem) ->

                        href = $(elem).attr 'href'

                        url: href.split('?')[1].split('&')[0].split('=')[1]
                        thumbURL: $(elem).find('img').attr 'src'

                    responseData =
                        guess: guess
                        similar: similarThumbs

                    client.hset 'more', imageUrl, JSON.stringify responseData

                    return res.json responseData
