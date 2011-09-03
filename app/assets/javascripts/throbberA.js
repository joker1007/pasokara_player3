var ThrobberA = function(options) {
    this.size = 24;
    this.color = "gray";
    this.lines = 16;
    this.roundTime = 1000;
    if (options) {
	for (var i in options) {
	    if (options[i])
		this[i] = options[i];
	}
    }
    this.canvas = document.createElement("canvas");
    this.canvas.width = this.canvas.height = this.size;
    this.ctx2d = this.canvas.getContext("2d");

    // pre calculate positions
    var centerPos = this.size / 2;
    var radius = this.size * 0.8 / 2;
    var positions = [];
    var eachRadian = 360 / this.lines * Math.PI / 180;
    for (var i = 1, n = this.lines; i <= n; i++) {
	var rad = eachRadian * i;
	var cosRad = Math.cos(rad), sinRad = Math.sin(rad);
	positions.push({
	    from: {x: centerPos + radius / 2 * cosRad, y: centerPos + radius / 2 * sinRad},
	    to: {x: centerPos + radius * cosRad, y: centerPos + radius * sinRad}
	});
    }
    this.positions = positions;
};
ThrobberA.prototype = {
    show: function(placeholder) {
	this.placeholder = placeholder;
	this.hide();
	placeholder.appendChild(this.canvas);
	this.highlightPos = 1;
	this._run();
	this.showing = true;
    },
    hide: function() {
	if (this.placeholder) {
	    this.stop();
    	    this.placeholder.innerHTML = "";
	    this.showing = false;
	}
    },
    restart: function() {
	if (!this.showing) {
	    return;
	}
	if (!this._runId) {
	    this._run();
	}
    },
    stop: function() {
	if (!this.showing) {
	    return;
	}
	if (this._runId) {
	    clearTimeout(this._runId);
	    this._runId = null;
	}
    },
    _run: function() {
	var canvas = this.canvas;
	var ctx = this.ctx2d;
	var highlightPos = this.highlightPos;
	var positions = this.positions;
	var strokeStyle = this.color;
	// clear canvas
	canvas.width = canvas.width;
	for (var i = 0, n = positions.length; i < n; i++) {
	    ctx.beginPath();
	    ctx.lineWidth = 2;
	    ctx.strokeStyle = strokeStyle;
	    var lineNum = i + 1;
	    if (lineNum == highlightPos) {
		ctx.globalAlpha = 1;
	    } else if (lineNum == highlightPos + 1 || lineNum == highlightPos - 1) {
		ctx.globalAlpha = 0.75;
	    } else {
		ctx.globalAlpha = 0.4;
	    }
	    var position = positions[i];
	    var from = position.from;
	    var to = position.to;
	    ctx.moveTo(from.x, from.y);
	    ctx.lineTo(to.x, to.y);
	    ctx.stroke();
	}
	if (highlightPos == this.lines) {
	    highlightPos = 0;
	} else {
	    highlightPos++;
	}
	this.highlightPos = highlightPos;
	var roundTime = Math.floor(this.roundTime / this.lines);
	// roundTime minimum is 50 milliseconds
	if (roundTime < 50) {
	    rountTime = 50;
	}
	var self = this;
	
	this._runId = setTimeout(function() {
	    self._run.call(self);
	}, roundTime);
    }
};