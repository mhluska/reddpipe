class window.Utils

    @isImageUrl: do ->

        types = ['jpg', 'png']

        (url) ->

            for type in types
                return true if Utils.endsWith url, type

            false

    @endsWith: (str, end) ->

        str.slice(str.length - end.length) is end

    # Concatenate in place.
    @concat: (arr1, arr2) ->

        arr1.push.apply arr1, arr2

