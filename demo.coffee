loader = new Loader
urls = []
index = 5

loader.loadNext (loaded) ->

    urls = loaded
    $('#goldie').append "<img src='#{urls[index]}' />"
    console.log urls

$(window).keydown (event) ->

    if event.which in [37, 39]

        switch event.which
            when 37 then index -= 1
            when 39 then index += 1

        $('#goldie').html("<img src='#{urls[index]}' />") if urls[index]
