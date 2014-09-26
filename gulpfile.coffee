gulp = require 'gulp'
open = require 'open'
es = require 'event-stream'
$ = do require 'gulp-load-plugins'
runSequence = require 'run-sequence'
bowerFiles = require 'main-bower-files'

paths =
  index:     'src/index.html'
  fonts:     'src/fonts/**/*'
  images:    'src/images/**/*'
  styles:    'src/styles/**/*.less'
  scripts:   'src/scripts/**/*.coffee'
  partials:  'src/partials/**/*.html'


production = false
prefix = 'app'

############################## Builds ##############################


gulp.task 'jshint', ['scripts'], ->
  gulp.src "#{ prefix }/scripts"
    .pipe $.plumber()
    .pipe $.jshint()
    .pipe $.jshint.reporter('jshint-stylish')
    .pipe $.jshint.reporter('fail')

# Compile coffee, generate source maps, trigger livereload
gulp.task 'scripts', ->
  gulp.src paths.scripts
    .pipe $.plumber()
    .pipe $.sourcemaps.init()
    .pipe gulp.dest "#{ prefix }/scripts"
    .pipe $.coffee()
    .pipe $.if production, $.ngAnnotate()
    .pipe $.if production, $.uglify()
    .pipe $.if production, $.concat 'app.js'
    .pipe $.sourcemaps.write()
    .pipe gulp.dest "#{ prefix }/scripts"
    .pipe $.if !production, $.connect.reload()

#Compile stylus, trigger livereload
gulp.task 'styles', ->
  gulp.src paths.styles
    .pipe $.plumber()
    .pipe gulp.dest "#{ prefix }/styles"
    .pipe $.sourcemaps.init()
    .pipe $.less(compress: production)
    .pipe $.sourcemaps.write('.')
    .pipe gulp.dest "#{ prefix }/styles"
    .pipe $.if !production, $.connect.reload()

#Copy images, trigger livereload
gulp.task 'images', ->
  gulp.src paths.images
    .pipe $.plumber()
    .pipe $.if production, $.imagemin()
    .pipe gulp.dest "#{ prefix }/images"
    .pipe $.if !production, $.connect.reload()

# Copy fonts
gulp.task 'fonts', ->
  gulp.src paths.fonts
    .pipe $.plumber()
    .pipe gulp.dest "#{ prefix }/fonts"

#Compile Jade, trigger livereload
gulp.task 'partials', ->
  gulp.src paths.partials
    .pipe $.plumber()
    .pipe gulp.dest "#{ prefix }/partials"
    .pipe $.if !production, $.connect.reload()


#Compile index.jade, inject compiled stylesheets, inject compiled scripts, inject bower packages
gulp.task 'index', ['scripts', 'styles'], ->
  gulp.src paths.index
    .pipe $.plumber()
    .pipe $.inject(es.merge(
      gulp.src bowerFiles(), read: no
    ,
      gulp.src "#{ prefix }/styles/**/*.css", read: no
    ,
      gulp.src ["#{ prefix }/scripts/**/*.js"], read: no
    ), ignorePath: "#{ prefix }")
    .pipe gulp.dest prefix
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
  gulp.src([
      "#{ prefix }/index.html",
      "#{ prefix }/styles",
      "#{ prefix }/scripts",
      '!app/bower_components',
      '!app/bower_components/**'], read: no)
    .pipe $.plumber()
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
