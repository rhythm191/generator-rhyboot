# Load plugins
g = require 'gulp'
$ = require('gulp-load-plugins')( camelize: true )
p = require './package.json'
browserSync = require 'browser-sync'

jsbanner = """
/**
 * <%= p.title %> - v<%= p.version %>
 *
 * <%= p.homepage %>
 *
 * Copyright 2015, <%= p.author %> (<%= p.homepage %>)
 * Released under the GNU General Public License v2 or later
 */
"""

cssbanner = """
/*
 Theme Name: <%= p.title %>
 Author: <%= p.author %>
 Author URI: <%= p.homepage %>
 Description: <%= p.description %>
 Version: <%= p.version %>
 License: GNU General Public License v2 or later
 License URI: http://www.gnu.org/licenses/gpl-2.0.html
 Text Domain:
 Tags:

 */
"""


# scripts
g.task 'scripts', ->
  g.src 'assets/scripts/'
    .pipe $.plumber
      errorHandler: $.notify.onError("Script: <%= error %>")
    .pipe $.webpack require './webpack.config.coffee'
    .pipe g.dest 'public/scripts'
    .pipe $.sourcemaps.init
      loadMaps: true
    .pipe $.uglify()
    .pipe $.sourcemaps.write()
    .pipe $.header jsbanner, p: p
    .pipe $.rename suffix: '.min'
    .pipe g.dest 'public/scripts'

g.task 'scripts:build', ->
  g.src 'assets/scripts/'
    .pipe $.webpack require './webpack.config.coffee'
    .pipe $.sourcemaps.init
      loadMaps: true
    .pipe $.uglify()
    .pipe $.sourcemaps.write()
    .pipe $.header jsbanner, p: p
    .pipe $.rename suffix: '.min'
    .pipe g.dest 'public/scripts'


# styles
g.task 'styles', ->
  g.src 'assets/styles/*.scss'
    .pipe $.plumber
      errorHandler: $.notify.onError("styles: <%= error %>")
    .pipe $.sourcemaps.init()
    .pipe $.sass(
      outputStyle: 'expanded',
      precision: 10,
      includePaths: ['.', 'bower_components']
    )
    .pipe $.pleeease(
      autoprefixer: ['last 2 version']
      minifier: false
    )
    .pipe g.dest 'public/styles'
    .pipe $.pleeease(
      autoprefixer: ['last 2 version']
      minifier: true
    )
    .pipe $.sourcemaps.write()
    .pipe $.header cssbanner, p: p
    .pipe $.rename suffix: '.min'
    .pipe g.dest 'public/styles'

g.task 'styles:build', ->
  g.src 'assets/styles/*.scss'
    .pipe $.sourcemaps.init()
    .pipe $.sass(
      outputStyle: 'expanded',
      precision: 10,
      includePaths: ['.', 'bower_components']
    )
    .pipe $.pleeease(
      autoprefixer: ['last 2 version']
      minifier: true
    )
    .pipe $.sourcemaps.write()
    .pipe $.header cssbanner, p: p
    .pipe $.rename suffix: '.min'
    .pipe g.dest 'public/styles'

# lint
g.task 'lint', [
  'lint:coffee'
  'lint:scss'
  ]

g.task 'lint:coffee', ->
  g.src 'assets/scripts/**/*.coffee'
    .pipe $.coffeelint()
    .pipe $.coffeelint.reporter()

g.task 'lint:scss', ->
  g.src 'assets/styles/**/*.scss'
    .pipe $.scssLint( config: 'scss-lint.yml' )


# copy files
g.task 'copy', [
    'copy:icons'
  ]

g.task 'copy:icons', ->
  g.src ['bower_components/bootstrap-sass/assets/fonts/**/*', 'bower_components/font-awesome/fonts/*']
    .pipe g.dest 'public/fonts'


g.task('clean', require('del').bind(null, ['.tmp', 'public']));

g.task 'serve', ->
  browserSync(
    notify: false
    port: 9000
    server:
      baseDir: ['./']
  )

  g.watch([
    'public/styles/**/*.css'
    'public/scripts/**/*.js'
    '*.html'
    ]).on 'change', browserSync.reload

  g.watch 'assets/styles/**/*.scss', ['styles']

  g.watch 'assets/scripts/**/*.coffee', ['scripts']

g.task 'build', ['clean', 'copy', 'scripts:build', 'styles:build']
