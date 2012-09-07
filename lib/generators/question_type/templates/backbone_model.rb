# Job of the class goes here

class SurveyBuilder.Models.<%= class_name %>Model extends Backbone.RelationalModel
  defaults: {
    type: '<%= class_name %>',
    content: 'Untitled question'
    mandatory: false
  }