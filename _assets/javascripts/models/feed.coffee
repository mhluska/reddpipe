# Categories view is separate from the Feed view but still listens on this
# model.
class window.FeedModel extends Backbone.Model
  @keyUp:   33
  @keyDown: 34

  defaults: category: 'hot'

  initialize: -> @setSubreddits('aww')

  # Subreddits can be a URL-friendly string or an Array. The collection stores
  # both. There are no getter functions; just use attributes.
  setSubreddits: (subreddits) ->
    if subreddits.join?
      @set('urlSubreddits', subreddits.join('+'), silent: true)
      @set('subreddits', subreddits)
    else
      @set('urlSubreddits', subreddits, silent: true)
      @set('subreddits', subreddits.split('+'))
