Config = require('../lib/config')

describe "Config", ->
  Given -> @raw = paths: {}, layouts: {}
  Given -> @subject = new Config(@raw)

  Invariant -> @raw == @subject.raw

  describe "#forFeed", ->
    Given -> @raw.paths.rss = @rssPath = "some/path"
    Given -> @raw.rssCount = @postCount = 2
    When -> @feedConfig = @subject.forFeed()
    Then -> expect(@feedConfig).toEqual {@rssPath, @postCount}

  describe "#forArchive", ->
    Given -> @raw.paths.archive = @htmlPath = "htmlPath"
    Given -> @raw.layouts.archive = @layoutPath = "layoutPath"
    When -> @archiveConfig = @subject.forArchive()
    Then -> expect(@archiveConfig).toEqual {@htmlPath, @layoutPath}
