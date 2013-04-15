module.exports = ((grunt) ->
    grunt.loadNpmTasks('grunt-shell')
    grunt.loadNpmTasks('grunt-coffeelint')
    grunt.loadNpmTasks('grunt-requirejs')

    grunt.initConfig
        shell:
            setup:
                stdout: true
                command: 'grunt/task/setup'
            link:
                stdout: true
                command: 'grunt/task/link'
            compile:
                stdout: true
                command: 'grunt/task/compile'

        coffeelint:
            app: [
                'src/js/*.coffee'
                'server/*.coffee'
                'server/routes/*.coffee'
                'server/public/js/*.coffee'
                ]
            options: grunt.file.readJSON('coffeelint.json')

        requirejs:
            compile:
                options:
                    almond: true
                    modules: [name: 'pipeline']
                    dir: 'build'
                    appDir: 'src'
                    baseUrl: 'js'
                    paths: {}
                    shim:
                        'lib/zepto': exports: '$'
                        'lib/underscore-lib': exports: '_'
                        'lib/backbone':
                            exports: 'Backbone'
                            deps: [
                                'lib/zepto'
                                'lib/underscore'
                            ]
                    optimize: 'none'
                    skipModuleInsertion: false
                    optimizeAllPluginResources: true
                    findNestedDependencies: true
                    preserveLicenseComments: false
                    logLevel: 0

    grunt.registerTask('default', ['shell', 'coffeelint', 'requirejs'])
)