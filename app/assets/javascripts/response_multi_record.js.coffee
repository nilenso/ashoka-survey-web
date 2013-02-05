@prepare_multi_record = (record_ids) ->
  $ ->
    wrap_with_div(record_id) for record_id in record_ids
    add_listener_to_create_record()

  wrap_with_div = (record_id) ->
    hidden = 'hidden' if $(".question[data-record-id=#{record_id}]").first().hasClass('hidden')
    $("div[data-record-id=#{record_id}]").wrapAll("<div class='record #{hidden}' data-record-id=#{record_id} />")

  add_listener_to_create_record = ->
    $('.create_record').click ->

      $.post('/records', { record : { response_id: $(this).data('responseId'), category_id: $(this).data('categoryId') }})
        .success (data) ->
          console.log('success')
          # Save response
          location.reload()
        .fail ->
          alert("Couldn't create the record.")

