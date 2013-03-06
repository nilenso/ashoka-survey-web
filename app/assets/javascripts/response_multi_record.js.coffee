@prepare_multi_record = (record_ids) ->
  $ ->
    window.dirty_response = false
    wrap_with_div(record_id) for record_id in record_ids

    $('.create_record').click ->
      if window.dirty_response
        confirm(I18n.t('js.new_record_unsaved_warning'))

    $('*').change(mark_dirty)
    $('.star > img').click(mark_dirty)

  wrap_with_div = (record_id) ->
    hidden = 'hidden' if $(".question[data-record-id=#{record_id}]").first().hasClass('hidden')
    record = $("<div class='record #{hidden}' data-record-id=#{record_id} />")
    $("div[data-record-id=#{record_id}]").wrapAll(record)
    delete_record_link = """
                          <a href= '/records/#{record_id}'
                             data-confirm='Are you sure?' class='delete_record'
                             data-method='delete' rel='nofollow'>
                             Delete Record
                          </a>
                         """
    $("div.record[data-record-id=#{record_id}]").prepend(delete_record_link)

  mark_dirty = () ->
    window.dirty_response = true
