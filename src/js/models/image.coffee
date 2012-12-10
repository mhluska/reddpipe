'use strict'

define [
    
    'lib/zepto'
    'lib/backbone'
    'constants'

], ($, Backbone, Const) ->

    Backbone.Model.extend

        initialize: ->

            @bind 'remove', -> @destroy()

        parse: (response) ->

            data = response.data

            url:           data.url
            score:         data.score
            title:         data.title
            thumbURL:      data.thumbnail
            largeThumbURL: data.url
            redditURL:     "#{Const.baseURL}/data.permalink"

        parseURL: (callback) ->

            [host, id] = @parseImageHostID()

            # TODO: This is debug info. It should go away in the final release.
            unless host and id
                console.warn "Couldn't parse #{@get 'url'}!"
                return @destroy()

            switch host

                when 'imgur'
                    
                    return $.ajax
                        type: 'GET'
                        url: "http://api.imgur.com/2/image/#{id}.json"
                        success: (data) =>

                            url = data.image?.links.large_thumbnail
                            @set 'largeThumbURL', url
                            callback()

                        error: =>
                            
                            # TODO: This most often happens when we run out of
                            # API tokens. In that case, guess the image
                            # extension as JPG and do an Image.load. If it
                            # works, great, use the image. If not drop the
                            # image.
                            console.warn 'Imgur API call failed.'
                            return @destroy()

                when 'quickmeme'

                    @set 'url', "http://i.qkme.me/#{id}.jpg"

            # Synchronous cases such as quickmeme reach this.
            callback()

        parseImageHostID: ->

            host2regex =
                imgur: /^http:\/\/imgur.com\/([A-Z0-9]+)$/i
                quickmeme: /^http:\/\/www.quickmeme.com\/meme\/([A-Z0-9]+).*$/i
                qkme: /^http:\/\/qkme.me\/([A-Z0-9]+).*$/i

            for own host, regex of host2regex
                matches = @get('url').match regex
                if matches?.length

                    host = 'quickmeme' if host is 'qkme'
                    return [host, matches[1]]

            [null, null]

