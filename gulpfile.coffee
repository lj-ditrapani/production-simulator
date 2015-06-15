gulp = require 'gulp'
runSequence = require 'run-sequence'
coffeelint = require 'gulp-coffeelint'
shell = require 'gulp-shell'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
gutil = require 'gulp-util'
fs = require 'fs'

gulp.task('default', ->
  runSequence('lint', 'coffee-compile', 'join-js', 'build')
)

gulp.task('lint', ->
  runSequence('coffee-lint')
)

gulp.task('coffee-lint', ->
  files = ['./coffee/*.coffee', './spec/*.coffee', './gulpfile.coffee']
  gulp.src(files)
    .pipe(coffeelint())
    .pipe(coffeelint.reporter())
)

gulp.task('coffee-compile', ->
  names = ['sim', 'station', 'team', 'summary']
  files = names.map((name) -> "./coffee/#{name}.coffee")
  gulp.src(files)
    .pipe coffee()
    .pipe concat('coffee.js')
    .pipe gulp.dest('./js')
    .on 'error', gutil.log
)

gulp.task('join-js', ->
  names = ['ljd-utils', 'coffee', 'main']
  files = names.map((name) -> "./js/#{name}.js")
  gulp.src(files)
    .pipe concat('all.js')
    .pipe gulp.dest('./js')
)

gulp.task('build', ->
  js = fs.readFileSync './js/all.js', 'utf8'
  css = fs.readFileSync './sim.css', 'utf8'
  template = fs.readFileSync './template.html', 'utf8'
  data = {js: js, css: css, file: ''}
  str = gutil.template(template, data)
  # Force dos newlines so Microsoft "Mark of the Web" (MotW) works
  str = str.replace(/\n/g, "\r\n")
  fs.writeFileSync('./sim.html', str)
)
