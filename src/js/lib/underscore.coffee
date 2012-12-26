'use strict'

define [

    'lib/underscore-lib'
    
], (_) ->

    _.templateSettings =
        basePath: basePath
        interpolate: /\{\{(.+?)\}\}/g
        escape:      /\{\{&(.+?)\}\}/g
    _
