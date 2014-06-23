### global angular: true ###
'use strict'

app = angular.module 'app'

class MainController
    @$inject = ['$scope']

    constructor: ($scope) ->
      @title = 'Main title'

app.controller 'MainController', MainController