@prepare_multi_record = (record_ids) ->
  $ ->
    window.dirty_response = false
    wrap_with_div(record_id) for record_id in record_ids

    $('.create_record').click ->
      if window.dirty_response
        confirm(I18n.t('js.new_record_unsaved_warning'))

    $('*').change(mark_dirty)

  wrap_with_div = (record_id) ->
    hidden = 'hidden' if $(".question[data-record-id=#{record_id}]").first().hasClass('hidden')
    $("div[data-record-id=#{record_id}]").wrapAll("<div class='record #{hidden}' data-record-id=#{record_id} />")

  mark_dirty = () ->
    window.dirty_response = true