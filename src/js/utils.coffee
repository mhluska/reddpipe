# TODO: Merge this with the server's CommonJS version of Utils. Possibly by
# switching to RequireJS on the backend?

define ->

    class Utils

        @endsWith: (string, end) ->

            string.substr(-end.length) is end
