### global angular:true ###
'use strict'

app = angular.module 'app', []

app.config ($compileProvider) ->
  $compileProvers.debugInfoEnabled false
