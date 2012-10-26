updateHits = (subreddit) ->

    name = subreddit
    elem = ($('.count-tag span').filter -> $(@).prev().text() is name)[0]

    if elem
        val = parseInt($(elem).text()) + 1
        $(elem).text val

    $.ajax
        type: 'PUT'
        url: "#{appRoot}/subreddit/update"
        data: name: subreddit
        error: -> $(elem).text val

loadImages = (field, feed, update = true) ->

    subreddit = field.val()
    field.removeClass 'error'

    deferred = feed.setSubreddit subreddit

    deferred?.done ->

        updateHits(subreddit) if update

$ ->

    # Load most popular subreddits.
    $.ajax
        type: 'GET'
        url: "http://reddit.com/reddits.json"
        dataType: 'jsonp'
        jsonp: 'jsonp'
        success: (result) ->

            data = subreddits: []

            for entry in result.data.children.slice 0, 10
                url = entry.data.url.substr 0, entry.data.url.length - 1
                name = url.split('/').pop()
                data.subreddits.push
                    'name': name
                    'url': url

            template = $('#tmpl-subreddit-list').text()
            node = $(Mustache.render template, data)
            node.insertBefore $('.most-searched')

    feed = new Feed $('#feed-wrap .feed')
    feed.error -> field.addClass 'error'

    field = $('.subreddit-field')

    $('.settings').submit do ->

        ready = true
        (event) ->

            event.preventDefault()

            return unless ready
            loadImages field, feed

            ready = false
            setTimeout ( -> ready = true), 2000

    # On load of Facebook like button, show tooltip.
    $('fb-like').on 'load', ->

        @width 100
        tooltip = $('<div class="tooltip"></div>')
        tooltip.appendTo document.body
        console.log 'loaded'
    
    $(window).keydown (event) ->

        # Set up image navigation using arrows and page up/down.
        if event.which in [33, 37]

            event.preventDefault()
            feed.showPrev()

        else if event.which in [34, 39]

            event.preventDefault()
            feed.showNext()

        # Set up image modal popup.
        else if event.which is 67

            event.preventDefault()
            feed.toggleModal()

    # Prevents hotkeys from taking effect while typing in the search box.
    field.keydown (event) -> event.stopPropagation()
            
    update = true
    unless field.val()
        update = false
        field.val 'aww'

    loadImages field, feed, update
