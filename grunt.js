// Generated by CoffeeScript 1.4.0

module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-coffeelint');
  grunt.loadNpmTasks('grunt-requirejs');
  grunt.loadNpmTasks('grunt-shell');
  grunt.initConfig({
    shell: {
      setup: {
        stdout: true,
        command: 'grunt/task/setup'
      },
      link: {
        stdout: true,
        command: 'grunt/task/link'
      },
      compile: {
        stdout: true,
        command: 'grunt/task/compile'
      }
    },
    coffeelint: {
      app: {
        files: ['src/js/*.coffee', 'server/*.coffee', 'server/routes/*.coffee', 'server/public/js/*.coffee'],
        options: grunt.file.readJSON('coffeelint.json')
      }
    },
    requirejs: {
      compile: {
        options: {
          almond: true,
          modules: [
            {
              name: 'pipeline'
            }
          ],
          dir: 'build',
          appDir: 'src',
          baseUrl: 'js',
          paths: {},
          skipModuleInsertion: false,
          optimizeAllPluginResources: true,
          findNestedDependencies: true,
          preserveLicenseComments: false,
          logLevel: 0
        }
      }
    }
  });
  return grunt.registerTask('default', 'shell coffeelint requirejs');
};
