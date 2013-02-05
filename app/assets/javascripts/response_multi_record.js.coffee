@prepare_multi_record = (record_ids) ->
  $ ->
    wrap_with_div(record_id) for record_id in record_ids

  wrap_with_div = (record_id) ->
    hidden = 'hidden' if $(".question[data-record-id=#{record_id}]").first().hasClass('hidden')
    $("div[data-record-id=#{record_id}]").wrapAll("<div class='record #{hidden}' data-record-id=#{record_id} />")
