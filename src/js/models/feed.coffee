'use strict'

define [

    'lib/backbone'
    'collections/images'
    
], (Backbone, Images) ->

    # This model is a wrapper for the images collection. It holds meta
    # information about images.
    Backbone.Model.extend

        defaults:
            
            subreddit: 'aww'
            after: null

        initialize: ->

            @set 'images', new Images @

        getNextImages: ->

            @getImages @get 'after'

        getImages: (after) ->

            @get('images').reset() unless after
            @get('images').fetch
                add: true
                type: 'GET'
                dataType: 'jsonp'
                data: $.param
                    limit: 25
                    count: 25
                    after: after
