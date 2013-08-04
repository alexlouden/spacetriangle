module.exports = (grunt) ->
  grunt.initConfig
  
    pkg: grunt.file.readJSON("package.json")
    
    # Check Coffee
    coffeelint:
      app: ['src/**/*.coffee']
          
    # Coffee -> JS
    coffee:
      build:
        expand: true
        cwd: "src/"
        src: ["**/*.coffee"]
        dest: "dist/"
        ext: ".js"
      
        options:
          sourceMap: true
          
    # Copy JS
    copy:
      js:
        files:
          [expand: true, src: ['src/**/*.js'], dest: 'dist/js/', filter: 'isFile']
          
    # SASS -> CSS
    compass:
      options:
        sassDir: "src/css"
        cssDir: "dist/css"
        raw: 'preferred_syntax = :sass\n'
      debugsass: true
    
    # Minify HTML
    htmlmin:
      dist:
        options:
          removeComments: true,
          collapseWhitespace: true,
          removeEmptyAttributes: true,
          removeCommentsFromCDATA: true,
          removeRedundantAttributes: true,
          collapseBooleanAttributes: true
        files:
          'dist/index.html': 'src/index.html'

    # Clean directories
    clean:
      build: ["dist"]
    
    # Server
    connect:
      server:
        options:
          port: 3000,
          base: 'dist/'

    # Watch
    watch:
      livereload:
        files: ["dist/**/*", "dist/*"]
        options:
          livereload: true
      js:
        files: ["Gruntfile.coffee", "src/**/*.coffee", "src/**/*.js"]
        tasks: ["coffeelint","coffee"]
      style:
        files: ["src/**/*.sass", "src/**/*.css"]
        tasks: ["compass"]
      html:
        files: ["src/**/*.html"]
        tasks: ["htmlmin"]
        
  grunt.loadNpmTasks "grunt-contrib-compass"
  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-cssmin"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-htmlmin"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-watch"
  
  grunt.registerTask "build", ["coffeelint", "coffee", "compass", "htmlmin"]
  
  grunt.registerTask "dev", ["clean:build", "build", "connect", "watch"]
  grunt.registerTask "default", ["dev"]
  
  