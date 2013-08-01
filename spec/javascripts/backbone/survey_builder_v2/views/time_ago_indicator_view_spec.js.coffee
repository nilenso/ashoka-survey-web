#= require spec_helper

describe "TimeAgoIndicatorView", ->
  clock = null
  beforeEach ->
    clock = sinon.useFakeTimers()
    $("body").html(SMT["templates/time_ago_indicator_view"]())

  afterEach -> clock.restore()

  context "#start", ->
    it "changes the label text to 'Saved' immediately", ->
      timeAgoIndicatorView = new SurveyBuilderV2.Views.TimeAgoIndicatorView
      timeAgoIndicatorView.start()
      $(".saving-indicator-time-ago").text().should.equal("Saved!")

    it "keeps the 'Saved' label for 5 seconds", ->
      timeAgoIndicatorView = new SurveyBuilderV2.Views.TimeAgoIndicatorView
      timeAgoIndicatorView.start()
      clock.tick(4999)
      $(".saving-indicator-time-ago").text().should.equal("Saved!")

    it "changes the label text to a relative time after 5 seconds", ->
      timeAgoIndicatorView = new SurveyBuilderV2.Views.TimeAgoIndicatorView
      timeAgoIndicatorView.start()
      clock.tick(5000)
      $(".saving-indicator-time-ago").text().should.equal("Last saved a few seconds ago")

    it "keeps changing the relative time every five seconds", ->
      timeAgoIndicatorView = new SurveyBuilderV2.Views.TimeAgoIndicatorView
      timeAgoIndicatorView.start()
      clock.tick(5000)
      expect(-> $(".saving-indicator-time-ago").text()).to.change.when -> clock.tick(40000)

  context "#reset", ->
    it "resets the interval timer", ->
      timeAgoIndicatorView = new SurveyBuilderV2.Views.TimeAgoIndicatorView
      timeAgoIndicatorView.start()
      timeAgoIndicatorView.reset()
      expect(-> $(".saving-indicator-time-ago").text()).to.not.change.when -> clock.tick(5000)

