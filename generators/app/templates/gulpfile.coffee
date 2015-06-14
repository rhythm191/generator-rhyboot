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
 Text Domain: rst
 Tags:

 This theme, like WordPress, is licensed under the GPL.
 Use it to make something cool, have fun, and share what you\ve learned with others.

 Resetting and rebuilding styles have been helped along thanks to the fine work of
 Eric Meyer http://meyerweb.com/eric/tools/css/reset/index.html
 along with Nicolas Gallagher and Jonathan Neal http://necolas.github.com/normalize.css/
 and Blueprint http://www.blueprintcss.org/
 */
"""


g.task 'scripts', ->
  g.src 'assets/scripts/'
    .pipe $.plumber()
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

g.task 'styles', ->
  g.src 'assets/styles/*.scss'
    .pipe $.plumber()
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
