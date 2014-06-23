# TODO: https://github.com/rafriki/angular-seed-web-starter-kit/blob/master/gulpfile.js
gulp = require 'gulp'
open = require 'open'
es = require 'event-stream'
loader = require 'gulp-load-plugins'
$ = loader()
runSequence = require 'run-sequence'
# TODO: gulp-sourcemaps, but needs update for gulp-concat first.

paths =
  index:     'src/index.jade'
  fonts:     'src/fonts/**/*'
  images:    'src/images/**/*'
  styles:    'src/styles/**/*.less'
  scripts:   'src/scripts/**/*.coffee'
  partials:  'src/partials/**/*.jade'


production = false

# Error are fatal, except when not in production
handleError = (error) ->
  $.util.log(error.message)
  if production
    process.exit(1)

############################## Builds ##############################


gulp.task 'jshint', ['scripts'], ->
  gulp.src 'app/scripts'
    .pipe $.jshint()
    .pipe $.jshint.reporter('jshint-stylish')
    .pipe $.jshint.reporter('fail')

# Compile coffee, generate source maps, trigger livereload
gulp.task 'scripts', ->
  gulp.src paths.scripts
    .pipe $.if !production, gulp.dest 'app/scripts'
    .pipe $.coffee
      bare: no
      sourceMap: !production
    .on 'error', handleError
    .pipe $.if production, $.ngmin()
    .pipe $.if production, $.uglify()
    .pipe $.if production, $.concat 'app.js'
    .pipe gulp.dest 'app/scripts'
    .pipe $.if !production, $.connect.reload()

#Compile stylus, trigger livereload
gulp.task 'styles', ->
  gulp.src paths.styles
    .pipe $.less({sourceMap: !production})
    .on 'error', handleError
    .pipe $.csso()
    .pipe gulp.dest 'app/styles'
    .pipe $.if !production, $.connect.reload()

#Copy images, trigger livereload
gulp.task 'images', ->
  gulp.src paths.images
    .pipe $.if production, $.imagemin()
    .pipe gulp.dest 'app/images'
    .pipe $.if !production, $.connect.reload()

# Copy fonts
gulp.task 'fonts', ->
  gulp.src paths.fonts
    .pipe gulp.dest 'app/fonts'

#Compile Jade, trigger livereload
gulp.task 'partials', ->
  gulp.src paths.partials
    .pipe $.jade pretty: !production
    .on 'error', handleError
    .pipe gulp.dest 'app/partials'


#Compile index.jade, inject compiled stylesheets, inject compiled scripts, inject bower packages
gulp.task 'index', ['scripts', 'styles'], ->
  gulp.src paths.index
    .pipe $.jade pretty: !production
    .on 'error', handleError
    .pipe $.inject(es.merge(
      $.bowerFiles read: no
    ,
      gulp.src './app/styles/**/*.css', read: no
    ,
      gulp.src './app/scripts/**/*.js', read: no
    ), ignorePath: '/app')
    .pipe gulp.dest 'app/'
    .pipe $.if !production, $.connect.reload()

# Launch server and open app in default browser
gulp.task 'serve', ['compile'], (cb) ->
  $.connect.server
    port       : 1337
    root       : 'app'
    livereload : yes
  open 'http://localhost:1337'
  runSequence 'watch', cb

# Clean build folder
gulp.task 'clean', ->
  gulp.src ['app/**/*', '!app/bower_components', '!app/bower_components/**'], read: no
    .pipe $.clean()

# Register tasks
gulp.task 'watch', ->
  gulp.watch paths.partials, ['partials']
  gulp.watch paths.scripts, ['scripts']
  gulp.watch paths.styles, ['styles']
  gulp.watch paths.images, ['images']
  gulp.watch paths.index, ['index']

# Compiles all parts
gulp.task 'compile', ['clean'], (cb) ->
  runSequence(['scripts', 'styles', 'images', 'partials', 'fonts'], 'index', cb)

# Production build
gulp.task 'build', ['clean'], (cb) ->
  production = true
  runSequence(['scripts', 'styles', 'images', 'partials', 'fonts'], 'index', cb)

gulp.task 'default', ['serve']
