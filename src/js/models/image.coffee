'use strict'

define [

    'lib/backbone'
    'collections/thumbs'
    'constants'
    'utils'

], (Backbone, Thumbs, Const, Utils) ->

    types = ['gif', 'jpg', 'jpeg', 'png']

    Backbone.Model.extend

        defaults:

            thumbsProcessed: false # Used to run code when all thumbs load.
            thumbs: null # Collection of related images.
            image: null # In-memory image data.
            position: 0 # Used in keyboard navigation algorithm.
            height: 0 # Also used in keyboard navigation algorithm.

        initialize: ->

            _.extend @, Backbone.Events

            # Does some parsing and extra API calls to get image info out of
            # this item. It modifies its own attributes and emits a 'ready'
            # event when that is done.
            @on 'add', =>
                @parseURL =>
                    @loadImage (image) =>
                        @set 'image', image
                        @trigger 'ready', @

            @set 'thumbs', new Thumbs()

        parse: (response) ->
            return unless response

            data = response.data
            url:           data.url
            votes:         data.score
            title:         data.title.replace /"/g, '&quot;'
            thumbURL:      data.thumbnail
            largeThumbURL: data.url
            redditURL:     Const.baseURL + data.permalink

        parseURL: (success) ->

            return success() if @hasImageURL()

            [host, id] = @parseImageHostID()

            # TODO: This is debug info. It should go away in the final
            # release.
            unless host and id
                console.warn "Couldn't parse #{@get 'url'}!"
                return @destroy()

            if host is 'imgur'

                imgurUrl = "http://api.imgur.com/2/image/#{id}.json"
                @getThumb imgurUrl, (data) =>

                    @set 'url', data.image.links.original
                    @set 'largeThumbURL', data.image.links.large_thumbnail

                    success()

            return

            # TODO: This is temporary. We should be showing the entire album.
            # The problem stems from the fact that albums and images are being
            # fetched into an image collection.
            if host is 'imgurAlbum'

                @getThumb "http://api.imgur.com/2/album/#{id}.json", (data) =>

                    firstImage = data.album.images[0]
                    @set 'url', firstImage.links.original
                    @set 'largeThumbURL', firstImage.links.large_thumbnail

                    success()

                return

            if host is 'quickmeme'

                url = "http://i.qkme.me/#{id}.jpg"
                @set
                    url: url
                    largeThumbURL: url

            # Synchronous cases such as quickmeme reach this.
            success()

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

        loadImage: (success) ->

            image = new Image()
            $(image).bind 'error', => @destroy()
            $(image).bind 'load',  -> success image
            image.src = @get 'largeThumbURL'

        hasImageURL: ->

            # Remove query parameters
            url = @get('url').split('?').shift()

            for type in types
                return true if Utils.endsWith url, type

            false

        scrollY: ->

            scrollY = @get 'position'
            padding = ($(window).height() - @get 'height')
            scrollY -= if padding > 0 then padding / 2 else 15
            Math.round scrollY
