### global angular:true ###
'use strict'

app = angular.module 'app', []

app.config ($compileProvider) ->
  $compileProvider.debugInfoEnabled false
