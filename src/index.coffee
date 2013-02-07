sysPath = require 'path'
mkdirp = require 'mkdirp'
_ = require 'lodash'
file = require 'file'
fs = require 'fs'

helper =
  test: (file) ->
    pathRuleTester = (rule, path) ->
      if rule.test(file) is true
        return {
          path: path
          file: file
        }
      else return null

    _(this)
      .map(pathRuleTester)
      .reject((x) -> x is null)
      .first()
  
  copy: (assert) ->
    path = sysPath.join this.public, assert.path, sysPath.basename assert.file
    mkdirp sysPath.dirname(path), (err) ->
      console.log err if err
      writeStream = fs.createWriteStream path
      readStream = fs.createReadStream assert.file
      readStream.pipe writeStream

module.exports = class BowerAssertsCopier
  brunchPlugin: yes

  constructor: (config) ->
    @public = config.paths?.public
    @asserts = config?.plugins?.bower?.asserts

  onCompile: (compiled) ->
    tester = _.bind helper.test, @asserts
    copier = _.bind helper.copy, public: @public

    file.walk "vendor", (nil, dirPath, dirs, files) ->
      _(files)
        .map((x) -> tester x)
        .compact()
        .each copier
