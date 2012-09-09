feed = new Feed document.getElementById 'feed'
loader = new Loader

loader.loadUrls (urls) ->

    feed.addImage url for url in urls
