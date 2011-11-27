@check_encode_status = (pasokara, count, callback) ->
  count = count + 1
  if count > 150
    alert "Video Loading Failed"
    return false

  $.ajax {
    type: "GET"
    dataType: "json"
    url: "/pasokaras/" + pasokara.id + "/encode_status.json?type=#{pasokara.type}"
    success: (data) ->
      if data.status
        callback(data) if callback
        if window.canvas_indicator?
          window.canvas_indicator.hide()
      else
        setTimeout(->
          check_encode_status({id: data.id, path: data.path, type: data.type}, count, callback)
        , 2000)
    error: (xhr) ->
      setTimeout(->
        check_encode_status({id: data.id, path: data.path, type: data.type}, count, callback)
      , 2000)
  }

@check_next = (deque) ->
  if deque
    url = "/pasokaras/play.json?deque=1"
  else
    url = "/pasokaras/play.json"

  $.ajax {
    type: "GET"
    dataType: "json"
    url: url
    success: (pasokara) ->
      check_encode_status(pasokara, 0, add_play_video_tag)
    error: (xhr) ->
      setTimeout(->
        check_next(false)
      , 2000)
  }

@add_play_video_tag = (pasokara) ->
  $("#video").append(
    $("#videoTemplate").render(pasokara)
  )
  $("#videoPlayer").bind("ended", ->
    check_queue_status()
    $(this).remove()
    window.canvas_indicator.reshow() if window.canvas_indicator?
    setTimeout(->
      check_next(true)
    , 5000)
  )

@add_preview_video_tag = (pasokara) ->
  width = 640
  height = 480
  $("#video").html(
    $("#videoTemplate").render(pasokara)
  )

@check_queue_status = () ->
  $.ajax {
    type: "GET"
    dataType: "json"
    url: "/queues"
    success: (queues) ->
      if queues.length > 0
        queues.shift()
      $("#queue_table ol").html(
        $("#queueListTemplate").render(queues)
      )
  }

@indicator_init = (position) ->
  console.log position
  options = if position? then {size: 80, position: position} else {size: 80}
  console.log options
  window.canvas_indicator = new CanvasIndicator(options)
  window.canvas_indicator.show(document.getElementById("indicator"))
