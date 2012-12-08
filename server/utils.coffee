module.exports = class Utils

    @endsWith: (string, end) ->

        string.substr(-end.length) is end
