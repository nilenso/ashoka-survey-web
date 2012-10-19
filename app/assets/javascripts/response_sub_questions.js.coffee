$ ->
  $('input[type=radio]').click ->
    console.log $(this).attr('name')
    sibling_options = $("input[name='#{$(this).attr('name')}']").not(this)
    sibling_options.each (index, option) ->
      console.log($(option))
      hide_sub_questions_of(option)
    
    show_sub_questions_of($(this))

  show_sub_questions_of = (option) ->
    $('.sub_question').each (index, elem) ->
      sub_question = $(this)
      sub_question.removeClass('hidden') if $(option).data('option-id') == sub_question.data('parent-id')

  hide_sub_questions_of = (option) ->
    # TODO: Wipe all content
    $('.sub_question').each (index, elem) ->
      sub_question = $(this)
      sub_question.addClass('hidden') if $(option).data('option-id') == sub_question.data('parent-id')
      # Recurse and hide the sub_question's sub_questions if the sub_question is a radio question.

