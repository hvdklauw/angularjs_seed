gulp = require 'gulp'
open = require 'open'
es = require 'event-stream'
$ = do require 'gulp-load-plugins'
runSequence = require 'run-sequence'
bowerFiles = require 'main-bower-files'

# TODO: gulp-plumber

paths =
  index:     'src/index.html'
  fonts:     'src/fonts/**/*'
  images:    'src/images/**/*'
  styles:    'src/styles/**/*.less'
  scripts:   'src/scripts/**/*.coffee'
  partials:  'src/partials/**/*.html'


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
    .pipe $.sourcemaps.init()
    .pipe gulp.dest 'app/scripts'
    .pipe $.coffee()
    .on 'error', handleError
    .pipe $.if production, $.ngAnnotate()
    .pipe $.if production, $.uglify()
    #.pipe $.if production, $.concatSourcemap 'app.js'
    .pipe $.sourcemaps.write()
    .pipe gulp.dest 'app/scripts'
    .pipe $.if !production, $.connect.reload()

#Compile stylus, trigger livereload
gulp.task 'styles', ->
  gulp.src paths.styles
    .pipe gulp.dest 'app/styles'
    .pipe $.sourcemaps.init()
    .pipe $.less(compress: production).on 'error', handleError
    .pipe $.sourcemaps.write()
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
    .pipe gulp.dest 'app/partials'


#Compile index.jade, inject compiled stylesheets, inject compiled scripts, inject bower packages
gulp.task 'index', ['scripts', 'styles'], ->
  gulp.src paths.index
    .pipe $.inject(es.merge(
      gulp.src bowerFiles(), read: no
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
  #open 'http://localhost:1337'
  runSequence 'watch', cb

# Clean build folder
gulp.task 'clean', ->
  gulp.src ['app/**/*', '!app/bower_components', '!app/bower_components/**'], read: no
    .pipe $.rimraf()

# Register tasks
gulp.task 'watch', ->
  gulp.watch paths.partials, ['partials']
  gulp.watch paths.scripts, ['scripts']
  gulp.watch paths.styles, ['styles']
  gulp.watch paths.images, ['images']
  gulp.watch paths.index, ['index']

# Compiles all parts
gulp.task 'compile', [], (cb) ->
  runSequence(['scripts', 'styles', 'images', 'partials', 'fonts'], 'index', cb)

# Production build
gulp.task 'build', (cb) ->
  production = true
  runSequence('clean', ['scripts', 'styles', 'images', 'partials', 'fonts', 'jshint'], 'index', cb)

gulp.task 'default', ['serve']
