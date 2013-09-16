class window.CategoriesView extends Backbone.View
  events: 'click': '_reloadListings'

  template: _.template(
    '<ul class="categories">' +
      '<li class="hot"><a href="/r/<%= urlSubreddits %>/hot">hot</a></li>' +
      '<li class="new"><a href="/r/<%= urlSubreddits %>/new">new</a></li>' +
      '<li class="controversial"><a href="/r/<%= urlSubreddits %>/controversial">controversial</a></li>' +
      '<li class="top"><a href="/r/<%= urlSubreddits %>/top">top</a></li>' +
    '</ul>'
  )

  initialize: ->
    @_listingCache = @options.listingCache

    @model.on('change', @render.bind(@))

  render: ->
    @$el.html(@template(@model.attributes))
    @_setActiveHeader(@_listingCache.category)

    @

  _reloadListings: (event) ->
    event.preventDefault()

    linkElem = $(event.target)
    category = linkElem.text()

    router.navigate(linkElem.attr('href'))
    @_setActiveHeader(category)

    @_listingCache.reset()
    @_listingCache.category = category
    @_listingCache.fetchSubreddits()

  _setActiveHeader: (category) ->
    @$el.find('li').removeClass('pure-menu-selected')
    @$el.find(".#{category}").addClass('pure-menu-selected')
