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
      check_encode_status(data["id"], data["path"], 0, add_video_tag)
    error: (xhr) ->
      setTimeout(->
        check_next()
      , 2000)
  }

@add_video_tag = (id, path, size...) ->
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
