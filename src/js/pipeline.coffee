'use strict'

# TODO: Can we build AMD module versions of these libraries to prevent having
# to shim?
require.config
    shim:
        'lib/zepto':      exports: '$'
        'lib/underscore': exports: '_'
        'lib/backbone':
            exports: 'Backbone'
            deps: [
                'lib/zepto'
                'lib/underscore'
            ]

define [

    'lib/backbone'
    'router'
    
], (Backbone, Router) ->

    console.log 'From pipeline.coffee: Hello World!'

    router = new Router()
