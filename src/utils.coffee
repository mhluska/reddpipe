class window.Utils

    @isImageUrl: do ->

        types = ['jpg', 'png']

        (url) ->

            for type in types
                return true if Utils.endsWith url, type

            false

    @endsWith: (str, end) ->

        str.slice(str.length - end.length) is end
