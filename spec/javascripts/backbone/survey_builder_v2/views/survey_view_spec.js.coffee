#= require spec_helper

describe "SurveyView", ->
  beforeEach ->
    $("body").html(SMT["templates/survey_view"]())
    @surveyHeaderEdit = $(".survey-header-edit")
    @surveyHeaderUpdateButton = $(".update-survey")
    @surveyHeaderAddQuestionButton = $(".add-question")
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

  it "should add a question to the left pane after clicking on 'Add Question'", ->
    @surveyHeaderAddQuestionButton.click()
    @surveyHeaderAddQuestionButton.click()
    numberOfQuestions = $(".survey-panes-left-pane").children().size()
    numberOfQuestions.should.be.equal(2)

  context "question selections", ->
    beforeEach ->
      @surveyHeaderAddQuestionButton.click()
      @surveyHeaderAddQuestionButton.click()

    it "clears the currently selected question", ->
      question = $(".survey-panes-left-pane").children().first()
      question.click()
      question.should.have.class("active")
      @view.clearLeftPaneSelection()
      question.should.not.have.class("active")

    it "keeps only the current question selected", ->
      [first, last] = $(".survey-panes-left-pane").children()
      first.click()
      $(first).should.have.class("active")
      $(last).should.not.have.class("active")

    it "selects the question that is added", ->
      @surveyHeaderAddQuestionButton.click()
      question = $(".survey-panes-left-pane").children().last()
      question.should.have.class("active")

