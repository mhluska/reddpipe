'use strict'

# TODO: Can we build AMD module versions of these libraries to prevent having
# to shim?
require.config
    shim:
        'lib/zepto': exports: '$'
        'lib/underscore-lib': exports: '_'
        'lib/backbone':
            exports: 'Backbone'
            deps: [
                'lib/zepto'
                'lib/underscore'
            ]

define [

    'lib/underscore'
    'lib/backbone'
    'router'
    
], (_, Backbone, Router) ->

    router = new Router()
