$ ->
  # TODO: Do this for dropdowns too
  $('input[type=radio]').click ->
    sibling_options = $("input[name='#{$(this).attr('name')}']").not(this)
    sibling_options.each (index, option) ->
      hide_sub_questions_of(option)

    show_sub_questions_of($(this))

  show_sub_questions_of = (option) ->
    $('.sub_question').each (index, elem) ->
      sub_question = $(this)
      sub_question.removeClass('hidden') if $(option).data('option-id') == sub_question.data('parent-id')

  hide_sub_questions_of = (option) ->
    $('.sub_question').each (index, elem) ->
      sub_question = $(this)
      if $(option).data('option-id') == sub_question.data('parent-id')
        clear_content_of sub_question
        sub_question.addClass('hidden') 
        hide_sub_questions_of(option) for option in sub_question.find('input[type=radio]')

  clear_content_of = (sub_question) ->
    $(sub_question).find('input').val('')
    $(sub_question).find('input').prop('checked', false) # For radio_buttons and check_boxes

