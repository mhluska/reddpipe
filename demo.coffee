loader = new Loader

loader.setup (url) ->

    $('#goldie').append "<img src='#{url}' />"

    $(window).keydown (event) ->

        if event.which in [37, 39]

            url = switch event.which
                when 37 then loader.prevUrl()
                when 39 then loader.nextUrl()

            console.log "url is #{url}"

            $('#goldie').html("<img src='#{url}' />")

