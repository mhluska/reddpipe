class window.Loader

    constructor: ->

        @_count = 0
        @_before = null
        @_after = null

    loadNext: (callback) ->

        @_count += 25

        params = "count=#{@_count}"
        params += "&after=#{@_after}" if @_before

        @loadUrls params, callback

    loadPrev: (callback) ->

        @_count -= 25

        params = "count=#{@_count}"
        params += "&before=#{@_before}" if @_before

        @loadUrls params, callback

    loadUrls: (params, callback) ->

        $.ajax
            type: 'GET'
            url: "http://www.reddit.com/r/realasians.json?#{params}"
            dataType: 'jsonp'
            jsonp: 'jsonp'

            success: (data) =>

                @_before = data.data.before
                @_after = data.data.after

                urls = (link.data.url for link in data.data.children)
                valid = (url for url in urls when Utils.isImageUrl url)

                callback valid

