$(->
  $('.nico_list_download').change(->
    id = $(this).attr('id').split('_').pop()
    $('#edit_nico_list_' + id).submit()
  )

  $('form.edit_nico_list').bind('ajax:success', (evt, data, status, xhr) ->
    $.gritter.add({
      title: "更新完了"
      text: "url: " + data.url + "<br>download: " + data.download
      time: 5000
    })
  ).bind('ajax:error', (evt, xhr, textStatus, thrown) ->
    error = $.parseJSON(xhr.responseText)
    for i of error
      $.gritter.add({
        title: "更新エラー"
        text: i + error[i]
        time: 5000
      })
  )

  $('form#new_nico_list').bind('ajax:success', (evt, data, status, xhr) ->
    $.gritter.add({
      title: "登録完了"
      time: 5000
    })
    row = $(data)
    $('#nico_list_table').append(row)
  ).bind('ajax:error', (evt, xhr, textStatus, thrown) ->
    error = $.parseJSON(xhr.responseText)
    for i of error
      $.gritter.add({
        title: "更新エラー"
        text: i + error[i]
        time: 5000
      })
  )

  $('#new_nico_list_box a').bind('click', (ev) ->
    ev.preventDefault()
    $('#new_nico_list_table').slideDown()
  )
)
