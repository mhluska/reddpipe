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

# TODO: This has to be here because Almond doesn't call require. Get the
# Gruntfile's insertRequire option working so this doesn't have to be
# explicitly called.
$ ->
    require 'pipeline'
