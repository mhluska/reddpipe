loader = new Loader
feed = new Feed loader, document.getElementById 'feed'

loader.loadUrls (urls) ->

    feed.addImage url for url in urls
