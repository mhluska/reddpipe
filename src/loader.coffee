class window.Loader

    constructor: ->

        @_count = 0
        @_after = null
        @_resultsPerPage = 25

    loadUrls: (callback) ->

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

                @_after = data.data.after

                urls = (link.data.url for link in data.data.children)
                valid = (url for url in urls when Utils.isImageUrl url)

                callback? valid

