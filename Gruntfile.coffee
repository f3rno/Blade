module.exports = (grunt) ->

  pkg = require "./package.json"

  ext = "html"

  if pkg.asPHP then ext = "php"

  ## Directory generation
  if pkg.buildDir.charAt(pkg.buildDir.length - 1) != "/"
    pkg.buildDir += "/"

  if pkg.srcDir.charAt(pkg.buildDir.length - 1) != "/"
    pkg.srcDir += "/"

  coffeeSrc = [ "coffee/app.coffee" ]
  jadeSrc = {}
  jadeSrc["#{pkg.buildDir}/index.#{ext}"] = "#{pkg.srcDir}jade/layout.jade"
  uglifySrc = []

  for u in pkg.uglifyCustom
    uglifySrc.push "#{pkg.buildDir}#{u}"

  uglifySrc.push "#{pkg.buildDir}coffee/app.js"

  for p in pkg.pages

    # Controller
    coffeeSrc.push "coffee/controllers/#{p}.coffee"
    uglifySrc.push "#{pkg.buildDir}coffee/controllers/#{p}.js"

    # Generate blank layout page
    jadeSrc["#{pkg.buildDir}/#{p}.#{ext}"] = "#{pkg.srcDir}jade/layout.jade"

    # Generate actual page HTML
    jadeSrc["#{pkg.buildDir}/pages/#{p}.html"] = "#{pkg.srcDir}jade/pages/#{p}.jade"

  # Prep source object
  uglifyFiles = {}
  uglifyFiles["#{pkg.buildDir}js/site.min.js"] = uglifySrc

  # Actual grunt config
  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"
    coffee:
      app:
        expand: true
        options:
          bare: true
        cwd: "#{pkg.srcDir}"
        src: coffeeSrc
        dest: pkg.buildDir
        ext: ".js"
    watch:
      coffeescript:
        files: coffeeSrc
        tasks: ["coffee"]
      stylus:
        files: [
          "#{pkg.srcDir}stylus/*.styl",
          "#{pkg.srcDir}stylus/**/*.styl"
        ]
        tasks: ["stylus", "copy"]
      jade:
        files: ["#{pkg.srcDir}jade/*.jade", "#{pkg.srcDir}jade/pages/*.jade"]
        tasks: ["jade"]
    stylus:
      app:
        options:
          yuicompress: true
          compress: true
        files:
          "./static/css/style.css": "./src/stylus/style.styl"
    copy:
      app:
        files: [
          expand: true
          cwd: "static"
          src: ["**"]
          dest: pkg.buildDir
        ,
          expand: true
          cwd: "bower_components"
          src: ["**"]
          dest: "#{pkg.buildDir}bower/"
        ]
    jade:
      app:
        files: jadeSrc
    uglify:
      app:
        files: uglifyFiles

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-jade"
  grunt.loadNpmTasks "grunt-contrib-stylus"
  grunt.loadNpmTasks "grunt-contrib-uglify"

  grunt.registerTask "clean", "delete build directory", ->
    done = this.async()
    require("child_process").exec "rm #{pkg.buildDir}/* -rf", (err, stdout) ->
      grunt.log.write stdout
      done err

  # Perform a full build
  grunt.registerTask "full", ["clean", "copy", "coffee", "stylus", "jade", "uglify"]
  grunt.registerTask "default", ["coffee", "stylus", "jade", "uglify"]