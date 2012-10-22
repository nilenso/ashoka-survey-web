@organize_sub_questions = ->
  # TODO: Do this for dropdowns too
  $('input[type=radio]').click ->
    sibling_options = $("input[name='#{$(this).attr('name')}']").not(this)
    sibling_options.each (index, option) ->
      hide_sub_questions_of(option)

    show_sub_questions_of($(this))

  show_sub_questions_of = (option) ->
    $(sub_question).removeClass('hidden') for sub_question in sub_questions_for(option)

  hide_sub_questions_of = (option) ->
    sub_questions_for(option).each (index) ->
      sub_question = $(this)
      clear_content_of sub_question
      sub_question.addClass('hidden') 
      hide_sub_questions_of(option) for option in sub_question.find('input[type=radio]')

  clear_content_of = (sub_question) ->
    $(sub_question).find('input').val('')
    $(sub_question).find('textarea').val('') # For multi_line questions
    $(sub_question).find('input').prop('checked', false) # For radio_buttons and check_boxes
    $(sub_question).find('option').prop('selected', false) # For drop_downs

  sub_questions_for = (option) ->
    $('.sub_question').filter ->
      sub_question = $(this)
      $(option).data('option-id') == sub_question.data('parent-id')
