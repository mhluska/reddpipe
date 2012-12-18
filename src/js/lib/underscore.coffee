'use strict'

define [

    'lib/underscore-lib'
    
], (_) ->

    _.templateSettings =
        interpolate: /\{\{(.+?)\}\}/g
        escape:      /\{\{&(.+?)\}\}/g
    _
