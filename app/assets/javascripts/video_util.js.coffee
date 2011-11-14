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
        if window.canvas_indicator?
          window.canvas_indicator.hide()
      else
        setTimeout(->
          check_encode_status(id, path, count, callback)
        , 2000)
    error: (xhr) ->
      setTimeout(->
        check_encode_status(id, path, count, callback)
      , 2000)
  }

@check_next = (deque) ->
  if deque?
    url = "/pasokaras/play.json?deque=1"
  else
    url = "/pasokaras/play.json"

  $.ajax {
    type: "GET"
    dataType: "json"
    url: url
    success: (data) ->
      check_encode_status(data["id"], data["path"], 0, add_play_video_tag)
    error: (xhr) ->
      setTimeout(->
        check_next()
      , 2000)
  }

@add_play_video_tag = (id, path, size...) ->
  size[0] = 640 unless size[0]?
  size[1] = 480 unless size[1]?
  video = $("<video>").attr("id", "video-#{id}").attr("width", size[0]).attr("height", size[1]).attr("controls", "controls").attr("autoplay", "autoplay").attr("src", path)
  video.addClass("fullscreen")
  video.bind("ended", ->
    $(this).remove()
    window.canvas_indicator.reshow()
    setTimeout(->
      check_next(true)
    , 5000)
  )
  $("#video").append(video)

@add_preview_video_tag = (id, path, size...) ->
  size[0] = 640 unless size[0]?
  size[1] = 480 unless size[1]?
  video = $("<video>").attr("id", "video-#{id}").attr("width", size[0]).attr("height", size[1]).attr("controls", "controls").attr("autoplay", "autoplay").attr("src", path)
  $("#video").append(video)

@indicator_init = ->
  window.canvas_indicator = new CanvasIndicator({size: 80})
  window.canvas_indicator.show(document.getElementById("indicator"))
