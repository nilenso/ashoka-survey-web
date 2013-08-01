#= require spec_helper

describe "SurveyView", ->
  beforeEach ->
    $("body").html(SMT["templates/survey_view"]())
    @surveyHeaderEdit = $(".survey-header-edit")
    @surveyHeaderUpdateButton = $(".update-survey")
    @surveyHeaderEdit.show()
    @server = sinon.fakeServer.create()
    @view = new SurveyBuilderV2.Views.SurveyView({ el: "#survey-builder-v2" })
    $.fx.off = true

  afterEach: ->
    @server.restore()
    $.fx.off = false

  context "header view", ->
    it "should collapse on successful save", ->
      @server.respondWith([200, { "Content-Type": "application/json" }, '{ "body": "OK" }'])
      @surveyHeaderUpdateButton.click()
      @server.respond()
      $(@surveyHeaderEdit).should.be.hidden

    it "should collapse and then uncollapse after the @server responsds on an unsuccessful save", ->
      @server.respondWith([400, { "Content-Type": "application/json" }, '{ "body": "OK" }'])
      @surveyHeaderUpdateButton.click()
      $(@surveyHeaderEdit).should.be.hidden
      @server.respond()
      $(@surveyHeaderEdit).should.not.be.hidden

  it "should set errors on the model on an unsuccessful save", ->
    errorResponse = { errors: { name: "foo",  description: "bar" }}
    @server.respondWith([400, { "Content-Type": "application/json" }, JSON.stringify(errorResponse)]);
    @surveyHeaderUpdateButton.click()
    @server.respond()
    @view.model.get("errors").name.should.equal("foo")
    @view.model.get("errors").description.should.equal("bar")
