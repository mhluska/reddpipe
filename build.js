({
    almond: true,
    modules: [{ name: 'pipeline' }],
    dir: 'build',
    appDir: 'source',
    baseUrl: 'js',
    paths: {
        lib: '../lib'
    },
    shim: {
        'lib/zepto': { exports: '$' },
        'lib/underscore-lib': { exports: '_' },
        'lib/backbone': {
            exports: 'Backbone',
            deps: [
                'lib/zepto',
                'lib/underscore'
            ]
        }
    },
    optimize: 'none',
    skipModuleInsertion: false,
    optimizeAllPluginResources: true,
    findNestedDependencies: true,
    preserveLicenseComments: false,
    logLevel: 0,
})
