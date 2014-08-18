#Angular Seed
AngularJS application boilerplate.

##Why?
[Because](http://xkcd.com/927/)

##Features
* Jade instead of html
* Coffee-Script instead of JS
* Less instead of css
* Automatic compilation
* Livereload without any plugins
* Development build with source maps
* Production build with optimizations
* Automatic scripts and stylesheets injection (including bower files)

##Installation

Clone repo using git
```sh
git clone https://github.com/hvdklauw/angularjs_seed
cd angularjs_seed
```

Install dependencies
```sh
npm install
bower install  # Should be called automatically after npm install
```

##Usage

###Running the App during Development
This command automatically compiles coffee, jade and less, injects bower components, generates source maps, starts livereload server and opens your app in the browser.
```sh
gulp serve
```

###Compiling app for development
This command compiles project and generates source maps. Output goes to ```sh app/``` folder
```
gulp compile
```

###Building the App for Production
This command compiles project and optimizes it for production. Output goes to ```sh app/``` folder
```
gulp build
```

##Directory layout

### Source

```sh
angularjs_seed
└── src
    ├── images               # image files
    ├── index.jade           # app layout file (the main jade template file of the app)
    ├── partials             # angular view partials (partial jade templates)
    ├── scripts              # coffeescripts
    │   ├── app.coffee       # application
    │   ├── controllers      # application controllers
    │   ├── directives       # application directives
    │   ├── filters          # custom angular filters
    │   └── services         # custom angular services
    └── styles               # less stylesheets
        └── style.less
```

### Development build

```sh
angularjs_seed
 app                      # development build
  ├── bower_components
  ├── images
  ├── index.html          # compiled app layout
  ├── partials            # compiled partials
  ├── scripts             # compiled scripts with source maps
  │   ├── app.js
  │   ├── app.js.map      # source map
  │   ├── controllers
  │   ├── directives
  │   └── services
  └── styles               # compiled stylesheets
      └── style.css
```

###Production build

```sh
 app                       # production build
  ├── bower_components
  ├── images               # optimized images
  │   └── amazon.png
  ├── index.html           # minified app layout
  ├── partials             # minified partials
  ├── scripts
  │   └── app.js           # minified and concatenated javascripts
  └── styles
      └── style.css        # minified and concatenated styles
```


##FAQ

### Q: I get a ENOSPC error for the watch task
Answer: You ran into the limit of your file system's watches, for unix use:
```sh
  echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
```

