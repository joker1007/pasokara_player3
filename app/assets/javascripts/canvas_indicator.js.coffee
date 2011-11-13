class Line
  constructor: (@from, @to) ->

class CanvasIndicator
  constructor: (@options) ->
    if @options?
      @size = @options.size ? 24
      @color = @options.color ? "gray"
      @lines = @options.lines ? 16
      @roundtime = @options.roundtime ? 1000
    else
      @size = 24
      @color = "gray"
      @lines = 16
      @roundtime = 1000

    @canvas = document.createElement("canvas")
    @canvas.width = @canvas.height = @size
    @ctx2d = @canvas.getContext("2d")
    @box = document.createElement("div")
    box_size = Math.round(@size * 1.1)
    box_padding = Math.round((@size * 1.1 - @size) / 2)
    box_style = "width: #{box_size}px; height: #{box_size}px; padding-left: #{box_padding}px; padding-top: #{box_padding}px;"
    if @options?.position?
      window_center = {x: Math.round(document.body.clientWidth / 2), y: Math.round(document.body.clientHeight / 2)}
      box_top = @options.position.top ? window_center.y - (box_size / 2)
      box_left = @options.position.left ? window_center.x - (box_size / 2)
      box_style += "z-index: 1000; position: fixed; top: #{box_top}px; left: #{box_left}px"
    @box.setAttribute("style", box_style)
    @box.setAttribute("class", "canvas_indicator")
    @box.appendChild(@canvas)
    @positions = []

    center = @size / 2
    radius = @size * 0.8 / 2
    degree = (360 / @lines)
    radian = @_degree2rad(degree)

    for i in [1..@lines]
      l = new Line(
        {x: @_edge_x(center, radius / 2.5, radian * i), y: @_edge_y(center, radius / 2.5, radian * i)},
        {x: @_edge_x(center, radius, radian * i), y: @_edge_y(center, radius, radian * i)}
      )
      @positions.push(l)

  _degree2rad: (degree) ->
    degree * Math.PI / 180

  _edge_x: (center, radius, radian) ->
    center + radius * Math.cos(radian)

  _edge_y: (center, radius, radian) ->
    center - radius * Math.sin(radian)

  show: (target) ->
    @target = target
    @hide()
    @target.appendChild(@box)
    @highlight_num = 1
    @start()
    @visible = true

  reshow: () ->
    if @target?
      @hide()
      @target.appendChild(@box)
      @highlight_num = 1
      @start()
      @visible = true

  hide: () ->
    @stop()
    @target.innerHTML = ""
    @visible = false

  stop: () ->
    if @timeout_id?
      clearTimeout(@timeout_id)
      @timeout_id = null
    else
      return

  restart: () ->
    if @timeout_id?
      return
    else
      @start()

  start: () ->
    @canvas.width = @canvas.width
    i = 0
    for line in @positions
      i += 1
      @ctx2d.beginPath()
      @ctx2d.lineWidth = 2
      @ctx2d.strokeStyle = @color

      line_num = i
      if line_num == @highlight_num
        @ctx2d.globalAlpha = 1
      else if (line_num == @highlight_num + 1) || (line_num == @highlight_num - 1)
        @ctx2d.globalAlpha = 0.75
      else 
        @ctx2d.globalAlpha = 0.5

      @ctx2d.moveTo(line.from.x, line.from.y)
      @ctx2d.lineTo(line.to.x, line.to.y)
      @ctx2d.stroke()

    if @highlight_num == @lines
      @highlight_num = 0
    else
      @highlight_num += 1

    interval = @roundtime / @lines
    if interval < 50
      interval = 50

    @timeout_id = setTimeout(=>
      @start()
    , interval)

@Line = Line
@CanvasIndicator = CanvasIndicator
