@check_encode_status = (id, path, count, callback) ->
  count = count + 1
  if count > 150
    alert "Video Loading Failed"
    return false

  $.ajax {
    type: "GET"
    dataType: "json"
    url: "/pasokaras/" + id + "/encode_status.json"
    success: (data) ->
      if data
        callback(id, path) if callback
        if window.throbber?
          window.throbber.hide()
      else
        setTimeout(->
          check_encode_status(id, path, count)
        , 2000)
    error: (xhr) ->
      setTimeout(->
        check_encode_status(id, path, count)
      , 2000)
  }

@throbber_init = ->
  window.throbber = new ThrobberA({size: 64})
  window.throbber.show(document.getElementById("throbber"))
