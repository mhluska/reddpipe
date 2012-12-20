# TODO: Merge this with the server's CommonJS version of Utils. Possibly by
# switching to RequireJS on the backend?

define [

    'lib/underscore'
    
], (_) ->

    class Utils

        @endsWith: (string, end) ->

            string.substr(-end.length) is end

        # http://stackoverflow.com/a/2048786/659910
        @DOMAttributes: (node) ->

            node = node.get 0 if $.zepto.isZ node

            attributes = {}
            for attr in node.attributes
                attributes[attr.nodeName] = attr.nodeValue

            attributes
