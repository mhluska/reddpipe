module.exports = (grunt) ->

    grunt.loadNpmTasks 'grunt-coffeelint'
    grunt.loadNpmTasks 'grunt-requirejs'
    grunt.loadNpmTasks 'grunt-shell'
    grunt.loadNpmTasks 'grunt-jade'

    grunt.initConfig

        shell:
            setup:   command: 'grunt/task/setup'
            link:    command: 'grunt/task/link'
            compile: command: 'grunt/task/compile'

        coffeelint:
            app:
                files: [
                    'src/js/*.coffee'
                    'server/*.coffee'
                    'server/routes/*.coffee'
                    'server/public/js/*.coffee'
                ]
                options: grunt.file.readJSON 'coffeelint.json'

        jade:
            html:
                src: ['server/views/templates/*.jade']
                dest: 'src/templates'
                options: client: false

        requirejs:
            almond: true
            modules: [name: 'pipeline']
            dir: 'build'
            appDir: 'src'
            baseUrl: 'js'
            paths: {}
            skipModuleInsertion: false
            optimizeAllPluginResources: true
            findNestedDependencies: true
            preserveLicenseComments: false
            logLevel: 0

    grunt.registerTask 'default', 'shell coffeelint jade requirejs'
