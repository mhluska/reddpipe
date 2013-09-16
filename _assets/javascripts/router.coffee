class window.Router extends Backbone.Router
  routes:
    '':                           'feed'
    'r/:subreddits(/)':           'feed'
    'r/:subreddits/:category(/)': 'feed'
    'favorites(/)':               'favorites'

  feed: (subreddits, category) ->
    listingCache = new ListingCache()
    feedModel = new FeedModel()

    # TODO(maros): This should be in AppView.
    feedModel.on('change', @_updateListingCache.bind(@, listingCache, feedModel))
    feedModel.set('category', category) if category
    feedModel.setSubreddits(subreddits) if subreddits
    @_updateListingCache(listingCache, feedModel)

    $ ->
      new CategoriesView(el: $('.pure-menu'), model: feedModel, listingCache: listingCache).render()
      new FeedView(el: $('.feed'), model: feedModel, listingCache: listingCache)

  favorites: -> console.log 'favorites'

  # TODO(maros): This should be in AppView.
  _updateListingCache: (listingCache, feedModel) ->
    listingCache.subreddits = feedModel.get('urlSubreddits')
    listingCache.category = feedModel.get('category')
