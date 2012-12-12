'use strict'

define [
    
    'lib/zepto'
    'lib/backbone'
    'utils'
    'constants'

], ($, Backbone, Utils, Const) ->

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

            return callback() if @hasImageURL()

            [host, id] = @parseImageHostID()

            # TODO: This is debug info. It should go away in the final release.
            unless host and id
                console.warn "Couldn't parse #{@get 'url'}!"
                return @destroy()

            if host is 'imgur'

                @getThumb "http://api.imgur.com/2/image/#{id}.json", (data) =>
                    @set 'largeThumbURL',
                        data.image?.links.large_thumbnail

                    callback()

                return

            # TODO: This is temporary. We should be showing the entire album.
            # The problem stems from the fact that albums and images are being
            # fetched into an image collection.
            if host is 'imgurAlbum'

                @getThumb "http://api.imgur.com/2/album/#{id}.json", (data) =>
                    @set 'largeThumbURL',
                        data.album.images[0].links.large_thumbnail

                    callback()

                return

            if host is 'quickmeme'

                @set 'url', "http://i.qkme.me/#{id}.jpg"

            # Synchronous cases such as quickmeme reach this.
            callback()

        hasImageURL: do ->

            types = ['gif', 'jpg', 'jpeg', 'png']

            ->
                url = @get 'url'

                # Remove query parameters
                url = url.split('?').shift()

                for type in types
                    return true if Utils.endsWith url, type

                false

        parseImageHostID: ->

            host2regex =
                imgur: /^http:\/\/imgur.com\/([A-Z0-9]{2,}).*$/i
                imgurAlbum: /^http:\/\/imgur.com\/a\/([A-Z0-9]+).*$/i
                quickmeme: /^http:\/\/www.quickmeme.com\/meme\/([A-Z0-9]+).*$/i
                qkme: /^http:\/\/qkme.me\/([A-Z0-9]+).*$/i

            for own host, regex of host2regex
                matches = @get('url').match regex
                if matches?.length

                    host = 'quickmeme' if host is 'qkme'
                    return [host, matches[1]]

            [null, null]

        getThumb: (url, callback) ->

            $.ajax
                type: 'GET'
                url: url
                success: callback

                error: (error) =>
                    
                    # TODO: This most often happens when we run out of
                    # API tokens. In that case, guess the image
                    # extension as JPG and do an Image.load. If it
                    # works, great, use the image. If not drop the
                    # image.
                    if error.status is 403
                        console.warn 'Imgur API call failed.'

                    return @destroy()
