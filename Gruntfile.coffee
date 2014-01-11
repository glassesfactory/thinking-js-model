_       = require "underscore"
path    = require "path"

#resouces
packagejson     = require "./package.json"
setupjson       = require "./setup.json"
routesjson      = require "./routes.json"
requirejsHelper = require "requirejs-helper"

generateRoutes =(prefix,routes, distDir)->
  settings = {}
  for v in routesjson.routes
    if v.build

      urls = v.url.split("/").splice(1)
      len = urls.length
      if len > 1
        jobName = "/" + urls[len - 2]
        settings = checkRoutesSetting(settings, jobName, distDir)
      else
        jobName = "/"
        settings = checkRoutesSetting(settings, jobName, distDir)
      settings[jobName].src.push prefix + v.url
  console.log "current routeing settings::", settings
  return settings

checkRoutesSetting =(settings, jobName, distDir)->
  if not settings.hasOwnProperty jobName
    settings[jobName] =
      src:[]
      dest: distDir + jobName
  return settings


generateDistObj =(targets)->
  console.log "generate dist obj"
  target = {}
  for k in targets
    target[k[0]] = k[1]
  return target

#generatorのホスト
GENERATOR_HOST = "http://localhost:3000"

#ディレクトリ類
#デプロイ用
$dist_dir        = setupjson.DIST
$assets_path     = setupjson.ASSET_DIR
$assets_dir      = path.join $dist_dir, $assets_path
$scripts_dir     = path.join $assets_dir, setupjson.SCRIPT_DIR
$stylesheets_dir = path.join $assets_dir, setupjson.STYLESHEET_DIR
$images_dir      = path.join $assets_dir, setupjson.IMAGE_DIR
#ソースコード
$src_dir         = setupjson.SRC
$coffee_dir      = path.join $src_dir, setupjson.COFFEE_DIR
$stylus_dir      = path.join $src_dir, setupjson.STYLUS_DIR
$jade_dir        = path.join $src_dir, setupjson.JADE_DIR
#作業領域
$tmp             = setupjson.TMP_DIR
$tmp_js          = path.join $tmp, setupjson.SCRIPT_DIR
$tmp_css         = path.join $tmp, $assets_path, setupjson.STYLESHEET_DIR


module.exports = (grunt)->
  #package.json から持ってくる
  _.each _.keys( packagejson.devDependencies ),(key)-> grunt.loadNpmTasks(key) if key.indexOf( "grunt-" ) == 0

  config =
    #ディレクトリを掃除する
    clean:
      default:[
        $dist_dir
        $tmp
      ]
      setup: [
        $dist_dir
        $tmp
        "libs/vendors"
      ]
      start: [
        "dist/*.html"
        "dist/**/*.html"
      ]
      afterSetup: [
        "setup"
      ]


    bower:
      install:
        options:
          targetDir: "libs/vendors"
          layout: "byType"
          install: true
          verbose: true
          cleanTargetDir: true


    concat:
      vendors:
        files:
          "setup/vendor.js" : grunt.file.expand("libs/vendors/**/*.js")

    copy:
      lib:
        files:[
          #bower で入るライブラリ
          "dist/assets/scripts/vendor.js" : "setup/vendor.js"
          "dist/assets/scripts/almond.js" : "libs/almond/almond.js"
        ]
      #メディア関連
      media:
        files:[
          {expand:true, src:["**/*.{gif,jpeg,jpg,png,mp3,mp4,ogg,wav,otf,ttf,swf}"], cwd:"media", dest:$dist_dir, filter:"isFile"}
        ]
      stylesheet:
        files:[
          {expand:true, src:["**/*.css"], cwd:"tmp", dest:$dist_dir, filter:"isFile"}
        ]



    #コーヒー用の設定
    coffee:
      #ソースコードをコンパイルする
      product:
        options:
          bare: false
        expand: true
        cwd: $coffee_dir
        src: ['*.coffee', '**/*.coffee']
        dest: $tmp_js
        ext: '.js'

      #開発サーバー用
      generator:
        options:
          bare: false
        expand: true
        cwd: 'generator/src'
        src: ['*.coffee', '**/*.coffee']
        dest: 'generator'
        ext: '.js'

      testdata:
        options:
          bare : false
        expand: true
        cwd  : 'testdata'
        src  : ['*.coffee', '**/*.coffee']
        dest : 'testdata'
        ext  : '.js'

    stylus:
      product:
        options:
          paths: [$stylus_dir + "/partial"]
          import : [
            "config"
            "partial"
            "reset"
          ]
        files:
          $tmp_css + "/main.css" : [$stylus_dir + "/main.styl"]

    #開発サーバーの起動
    express:
      dev:
        options:
          background: true
          delay: 100
          script: "generator/app.js"

    #ビルド用。generatorから html を取ってくる
    "curl-dir":generateRoutes(GENERATOR_HOST, routesjson.routes, "dist")

    #ファイル変更の監視
    watch:
      coffee:
        files: [$coffee_dir + "/*.coffee", $coffee_dir + "/**/*.coffee"]
        tasks: ["coffee:product", "requirejs"]
      generator:
        files: ["generator/src/**/*.coffee", "generator/src/*.coffee"]
        tasks: ["coffee:generator", "express:dev"]
        options:
          nospawn: true
      testdata:
        files: ["testdata/**/*.coffee", "testdata/*.coffee"]
        tasks: ["coffee:testdata"]


      stylus:
        files: ["src/stylus/*.styl", "src/stylus/**/*.styl"]
        tasks: ["stylus:product", "copy:stylesheet"]


  grunt.initConfig(config)

  #ここに生成したいファイルを追加していく
  requirejsHelper.config
    dist:
      inDir  : $tmp_js
      outDir : $scripts_dir
      names: [
        "main"
      ]

  #余計なことしないためにデフォルトを封印
  grunt.registerTask "default", []



  grunt.registerTask "requirejs", "requirejs(:release)", (release)->
    done = @async()
    requirejsHelper.build release == "release", ()->
      console.info "Complete"
      done()

  grunt.registerTask "setup", ()->
    grunt.task.run [
      "clean:setup"
      "bower:install"
      "concat:vendors"
      "copy:lib"
      "clean:afterSetup"
    ]

  grunt.registerTask "start", ()->
    grunt.task.run [
      "clean:start"
      "copy:media"
      "stylus"
      "copy:stylesheet"
      "coffee:product"
      "requirejs"
      "express:dev"
      "watch"
    ]

  #ビルドする。これがサーバー上で実行される
  grunt.registerTask "build", ()->
    grunt.task.run [
      "express:dev"
      "clean:default"
      "coffee:product"
      "stylus:product"
      "concat:vendors"
      "copy:media"
      "copy:stylesheet"
      "copy:lib"
      "requirejs:release"
      "curl-dir"
    ]

  # grunt.registerTask "deploy"
