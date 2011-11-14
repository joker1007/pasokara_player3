@add_video_tag = (id, path, size...) ->
  size[0] = 640 unless size[0]?
  size[1] = 480 unless size[1]?
  video = $("<video>").attr("id", "video-#{id}").attr("width", size[0]).attr("height", size[1]).attr("controls", "controls").attr("autoplay", "autoplay").attr("src", path)
  $("#video").append(video)

