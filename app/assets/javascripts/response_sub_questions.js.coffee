@organize_sub_questions = ->
  # Copy the mutli-choice options' value to the data-option-id field
  # Couldn't do this in formtastic. If you figure that out, remove this.
  $ ->
    set_nesting_level()

    $('input[type=checkbox]').each ->
      option_id = parseInt($(this).val())
      $(this).data('option-id', option_id)

  $('input[type=radio]').click ->
    sibling_options = $("input[name='#{$(this).attr('name')}']").not(this)
    sibling_options.each (index, option) ->
      hide_sub_questions_of(option)
    show_sub_questions_of($(this))

  $('input[type=checkbox]').click ->
    if this.checked
      show_sub_questions_of($(this))
    else
      hide_sub_questions_of($(this))

  $('select').change ->
    option = this.options[this.selectedIndex]
    sibling_options = $(this.options).not(option)
    sibling_options.each (index, option) ->
      hide_sub_questions_of(option)
    show_sub_questions_of(option)

  $('form.formtastic').submit -> remove_hidden_sub_questions()


  initialize = ->
    show_sub_questions_of(option) for option in $('input[type=radio]:checked,input[type=checkbox]:checked,option:checked')

  show_sub_questions_of = (option) ->
    for sub_question in sub_questions_for(option)
      $(sub_question).removeClass('hidden')

    update_visible_records()

  hide_sub_questions_of = (option) ->
    sub_questions_for(option).each (index) ->
      sub_question = $(this)
      clear_content_of sub_question
      sub_question.addClass('hidden')
      hide_sub_questions_of(option) for option in sub_question.find('input[type=radio],input[type=checkbox],option')

    update_visible_records()

  clear_content_of = (sub_question) ->
    $(sub_question).find('input[type!=hidden]').val('')
    $(sub_question).find('textarea').val('') # For multi_line questions
    $(sub_question).find('input').prop('checked', false) # For radio_buttons and check_boxes
    $(sub_question).find('option').prop('selected', false) # For drop_downs
    $(sub_question).find('.rating').find('li.hidden').children('input').val('') # Rating question
    $(sub_question).find('.star').raty('cancel')

  sub_questions_for = (option) ->
    record_id = $(option).closest('.question').data('recordId')
    option_id = $(option).data('option-id')
    if record_id
      sub_questions = $(".sub_question[data-parent-id=#{option_id}][data-record-id=#{record_id}]")
    else
      sub_questions = $(".sub_question[data-parent-id=#{option_id}]")

    sub_questions.each ->
      sub_question = $(this)
      sub_questions.push(sub_questions_for_category(sub_question, record_id)) if (sub_question.hasClass('category'))

    $(_(sub_questions).flatten())

  sub_questions_for_category = (category, record_id) ->
    category_id = $(category).data('id')
    if record_id
      sub_questions = $(".sub_question[data-category-id=#{category_id}][data-record-id=#{record_id}]")
    else
      sub_questions = $(".sub_question[data-category-id=#{category_id}]")


    sub_questions.each ->
      sub_question = $(this)
      sub_questions.push(sub_questions_for_category(sub_question, record_id)) if (sub_question.hasClass('category'))

    _(sub_questions).flatten()

  remove_hidden_sub_questions = () ->
    $('.hidden.sub_question:not(.category)').each ->
      $(this).find(".allow-destroy").val(true)

  set_nesting_level = () ->
    $('.category,.question').each ->
      sub_question = $(this)
      nesting_level = $(sub_question).data('nesting-level') - 1
      sub_question.css('margin-left', nesting_level * 15)

      record = $(sub_question).closest('.record')
      record.css('margin-left', nesting_level * 15) if record

  update_visible_records = () ->
    $('div.record').each ->
      record = $(this)
      # If a single child of the record is visible, show the record
      if record.children('div:not(.hidden)').length > 0
        record.removeClass("hidden")
      else
        record.addClass('hidden')


  $ ->
    initialize()
