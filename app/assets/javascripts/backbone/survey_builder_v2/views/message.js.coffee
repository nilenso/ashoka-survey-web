class SurveyBuilderV2.Views.GlobalMessageBus
  constructor: ->
    @vent = _.extend({}, Backbone.Events);

  bind: (event, callback) =>
    @vent.on(event, callback)

  trigger: (event, params) =>
    @vent.trigger(event, params)
