#= require ./vendor/html5shiv.js
#= require ./vendor/es5-shim-min.js
#= require ./vendor/jquery-min.js
#= require ./vendor/underscore-min.js
#= require_tree ./vendor

#= require_tree .
#= require ./router

window.router = new Router()
Backbone.history.start(pushState: true)
router.navigate(location.pathname, trigger: true)

$ -> FastClick.attach(document.body)
