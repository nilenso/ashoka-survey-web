@prepare_multi_record = (records, @show_mode) ->
  $ ->
    window.dirty_response = false
    wrap_with_div(record) for record in records
    add_delete_links(record) for record in records

    $('.create_record').click ->
      if window.dirty_response
        confirm(I18n.t('js.new_record_unsaved_warning'))

    $('*').change(mark_dirty)
    $('.star > img').click(mark_dirty)

  wrap_with_div = (record) ->
    [record_id, category_id] = record
    hidden = 'hidden' if $(".question[data-record-id=#{record_id}]").first().hasClass('hidden')
    record = $("<div class='record #{hidden}' data-record-id=#{record_id} data-category-id=#{category_id} />")
    $("div[data-record-id=#{record_id}]").wrapAll(record)

  add_delete_links = (record) ->
    [record_id, category_id] = record
    delete_record_link = """
                         <a href= '/records/#{record_id}'
                         data-confirm='Are you sure?' class='delete_record'
                         data-method='delete' rel='nofollow'>
                         Delete Record
                         </a>
                         """
    if $("div.record[data-category-id=#{category_id}]").length > 1
      $("div.record[data-record-id=#{record_id}]").prepend(delete_record_link) unless @show_mode

  mark_dirty = () ->
    window.dirty_response = true
