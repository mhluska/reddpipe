class window.ListingModel extends Backbone.Model
  defaults:
    active: false

  parse: (response) ->
    _.pick(response.data, 'url', 'domain', 'permalink', 'title', 'subreddit',
      'score', 'ups', 'downs')

  resolveImage: (callback) ->
    return callback(@) unless @get('domain') is 'imgur.com'

    imgurAlbumMatch = @get('url').match(/imgur\.com\/a\/([a-zA-Z0-9]+)/)
    imgurImageMatch = @get('url').match(/imgur\.com\/([a-zA-Z0-9,]+)$/)

    if imgurImageMatch
      # Some Imgur image URLs come in with a comma separated list of IDs. Let's
      # just keep the first one.
      url = @get('url').split(',').shift()
      @set('url', "http://i.imgur.com/#{imgurImageMatch[1]}.jpg")
      return callback(@)

    if imgurAlbumMatch
      albumModel  = new ImgurAlbumModel(albumID: imgurAlbumMatch[1])

      # TODO(maros): Account for the fetch failing and callback not getting
      # triggered.
      return albumModel.fetch(
        headers: Authorization: 'Client-ID c1ed51a9e985a23'
        success: (=>
          image = albumModel.get('images').shift()
          return @destroy() unless image
          @set('url', image)
          callback(@)
        )
        error: @destroy.bind(@)
      )

    callback(@)

class window.ListingCollection extends Backbone.Collection
  model: ListingModel

class window.ListingCache extends Backbone.Collection
  model: ListingModel

  url: -> "http://www.reddit.com/r/#{@subreddits}/#{@category}.json?jsonp=?"

  initialize: ->
    @_loadIndex = 0
    @_after = null
    @_xhr = null

  reset: ->
    super()
    @_loadIndex = 0

  parse: (response) ->
    @_after = response.data.after

    # Rarely the API returns duplicate URLs. We get rid of them here. This won't
    # get rid of duplicates across the entire collection; only within a batch
    # from a fetch call. The use case is so small that it's not worth
    # implementing fully.
    _.uniq(response.data.children, (item) -> item.data.url)

  getPage: ->
    @_loadIndex += 10
    @slice(@_loadIndex - 10, @_loadIndex)

  fetchSubreddits: ->
    @_xhr?.abort()
    @_xhr = @_fetchSubreddits()

  _fetchSubreddits: ->
    # TODO(maros): Later we will want to load another chunk after 90% have been
    # viewed.
    return if @length >= 500

    @fetch(remove: false, success: @_fetchSubreddits.bind(@), data:
      sort: 'top'
      t: 'all'
      limit: 100
      after: @_after
    )
