module.exports = ((grunt) ->
    grunt.loadNpmTasks('grunt-shell')
    grunt.loadNpmTasks('grunt-coffeelint')

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

    grunt.registerTask('default', ['shell', 'coffeelint', 'requirejs'])
)
