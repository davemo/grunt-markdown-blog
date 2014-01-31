Layout = null
NullLayout = null
SandboxedModule = require('sandboxed-module')

Given -> @extendedContext = jasmine.createSpy("extendedContext")
Given -> @layout = jasmine.createSpy("layout").andReturn(@html = jasmine.createSpy("html"))
Given -> Layout = SandboxedModule.require '../lib/layout',
  requires:
    'grunt': @grunt =
      warn: jasmine.createSpy("grunt.warn")
      file:
        exists: jasmine.createSpy("grunt.file.exists").andReturn(true)
        read: jasmine.createSpy("grunt.file.read")
    'underscore': @_ = do =>
      _ = jasmine.createSpy("underscore")
      _.mixin = ->
      _.extend = jasmine.createSpy("extend").andReturn(@extendedContext)
      _.template = jasmine.createSpy("template").andReturn(@layout)
      _.tap = require('underscore').tap
      _.andReturn(_)
    './null_layout': NullLayout = jasmine.createSpy("NullLayout")


describe "Layout", ->
  Given -> @templatePath = "somePath.us"
  Given -> @templateContents = "someFileContents"
  Given -> @grunt.file.read.andReturn(@templateContents)
  When -> @subject = new Layout @templatePath, @context

  context "with valid template file", ->
    Given -> @grunt.file.exists.andReturn(true)
    Then -> @subject instanceof Layout
    Then -> expect(@grunt.warn).not.toHaveBeenCalled()

    describe "reads template file", ->
      Then -> expect(@grunt.file.read).toHaveBeenCalledWith @templatePath

    describe "parses file as underscore template", ->
      Then -> expect(@_).toHaveBeenCalledWith @templateContents
      Then -> expect(@_.template).toHaveBeenCalled()


  context "with invalid template file", ->
    Given -> @grunt.file.exists.andReturn(false)
    Then -> @subject instanceof NullLayout

    context "non-empty template path", ->
      Given -> @templatePath = "some/nonexistant/file.us"
      Then -> expect(@grunt.warn).toHaveBeenCalled()

    context "undefined template path", ->
      Given -> @templatePath = undefined
      Then -> expect(@grunt.warn).not.toHaveBeenCalled()
    context "null template path", ->
      Given -> @templatePath = null
      Then -> expect(@grunt.warn).not.toHaveBeenCalled()


  describe "#htmlFor", ->
    When -> @resultHtml = @subject.htmlFor(@specificContext)

    describe "merges contexts", ->
      Given -> @context = jasmine.createSpy("context")
      Given -> @specificContext = jasmine.createSpy("specificContext")
      Then -> expect(@_).toHaveBeenCalledWith @context
      Then -> expect(@_.extend).toHaveBeenCalledWith @specificContext

    describe "hydrates template with context", ->
      Then -> expect(@layout).toHaveBeenCalledWith @extendedContext
      Then -> @resultHtml == @html
