class window.Loader

    constructor: ->

        @_urls = []
        @_urlsIndex = 0

        @_count = 0
        @_after = null
        @_resultsPerPage = 25

    # Loads an initial group of urls.
    setup: (callback) ->
        
        @_addUrls('next').done =>
            
            @_urlsIndex = Math.floor(@_urls.length / 2)
            console.log "urlsIndex is #{@_urlsIndex}"
            callback @_urls[@_urlsIndex]

    nextUrl: ->
        
        @_getUrl 'next'

    prevUrl: ->

        @_getUrl 'prev'

    _getUrl: (direction) ->

        unless @_urls.length
            throw new Error 'No initial urls. Did you call loader.setup?'

        @_addUrls(direction) if @_indexNearBoundaries()

        if @_urlsIndex > 0 and @_urlsIndex < @_urls.length

            @_urlsIndex += if direction is 'next' then 1 else -1

        @_urls[@_urlsIndex]

    _addUrls: (direction) ->

        @_loadUrls (newUrls) =>

            if direction is 'next'

                Utils.concat @_urls, newUrls

            else if direction is 'prev'

                @_urls = newUrls.concat @_urls
                @_urlsIndex += newUrls.length

            console.log 'urls is now...'
            console.log @_urls
            console.log ''

    _indexNearBoundaries: ->

        length = @_urls.length
        lowerIndex = 5
        upperIndex = length - lowerIndex

        @_urlsIndex <= lowerIndex or @_urlsIndex >= upperIndex

    _loadUrls: (callback) ->

        @_count += @_resultsPerPage

        url = 'http://www.reddit.com/r/aww'

        params = "limit=#{@_resultsPerPage}&count=#{@_count}"
        params += "&after=#{@_after}" if @_after

        $.ajax
            type: 'GET'
            url: "#{url}.json?#{params}"
            dataType: 'jsonp'
            jsonp: 'jsonp'

            success: (data) =>

                @_before = data.data.before
                @_after = data.data.after

                urls = (link.data.url for link in data.data.children)
                valid = (url for url in urls when Utils.isImageUrl url)

                callback? valid

