### global angular: true ###
'use strict'

app = angular.module 'app'

class IndexController
    @$inject = []

    constructor: ->
        @title = 'Index title'

    test: ->
        console.log 'Hello world'


app.controller 'IndexController', IndexController
