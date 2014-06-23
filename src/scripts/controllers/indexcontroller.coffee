### global angular: true ###
'use strict'

app = angular.module 'app'

class IndexController
    @$inject = ['$scope']

    constructor: ($scope) ->
      @title = 'Index title'

app.controller 'IndexController', IndexController