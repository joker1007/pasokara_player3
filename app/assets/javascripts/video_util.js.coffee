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
  width = 640
  height = 480
  video = $("<video>").attr("id", "video-#{pasokara.id}").attr("width", width).attr("height", height).attr("controls", "controls").attr("autoplay", "autoplay").attr("src", pasokara.path)
  video.addClass("fullscreen")
  video.bind("ended", ->
    $(this).remove()
    window.canvas_indicator.reshow() if window.canvas_indicator?
    setTimeout(->
      check_next(true)
    , 5000)
  )
  $("#video").append(video)

@add_preview_video_tag = (pasokara) ->
  width = 640
  height = 480
  video = $("<video>").attr("id", "video-#{pasokara.id}").attr("width", width).attr("height", height).attr("controls", "controls").attr("autoplay", "autoplay").attr("src", pasokara.path)
  $("#video").append(video)

@indicator_init = ->
  window.canvas_indicator = new CanvasIndicator({size: 80})
  window.canvas_indicator.show(document.getElementById("indicator"))
