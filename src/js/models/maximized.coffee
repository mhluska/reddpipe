'use strict'

define [

    'lib/backbone'
    
], (Backbone) ->

    Backbone.Model.extend

        # TODO: Document these
        defaults:

            maximized: true
            title:     null
            url:       null
