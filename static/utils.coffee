class window.Utils

    @isImageUrl: do ->

        types = ['jpg', 'png']

        (url) ->

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
                return [host, matches[1]]

        [null, null]

    @endsWith: (str, end) ->

        str.slice(str.length - end.length) is end
