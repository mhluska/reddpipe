class window.Utils

    @isImageUrl: do ->

        types = ['jpg', 'png']

        (url) ->

            for type in types
                return true if Utils.endsWith url, type

            false

    @isImgurUrl: (url) -> /^http:\/\/imgur.com\/[A-Z0-9]+$/i.test url

    @endsWith: (str, end) ->

        str.slice(str.length - end.length) is end
