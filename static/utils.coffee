class window.Utils

    @isImageUrl: do ->

        types = ['gif', 'jpg', 'png']

        (url) ->

            # Remove query parameters
            url = url.split('?').shift()

            for type in types
                return true if Utils.endsWith url, type

            false

    @urlInfo: (url) ->

        hosts =
            imgur: /^http:\/\/imgur.com\/([A-Z0-9]+)$/i
            quickmeme: /^http:\/\/www.quickmeme.com\/meme\/([A-Z0-9]+).*$/i
            qkme: /^http:\/\/qkme.me\/([A-Z0-9]+).*$/i

        for own host, regex of hosts
            matches = url.match regex
            if matches?.length

                host = 'quickmeme' if host is 'qkme'
                return [host, matches[1]]

        [null, null]

    @endsWith: (str, end) ->

        str.slice(str.length - end.length) is end

    @truncate = (val) ->

        return unless val >= 1000
        
        val = val / 1000
        val = Math.round(val * 10) / 10
        val + 'k'

