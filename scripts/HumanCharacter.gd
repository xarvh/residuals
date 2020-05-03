extends Node2D


var time = 0
var directionIsLeft = true
var isWalking = true



func _ready():
    pass


func _process(delta):
    time += delta

    var duration = 1
    var normalizedFrameTime = fposmod(time, duration) / duration

    var frame
    if isWalking:
      var totalFrames = 6
      frame = floor(normalizedFrameTime * (totalFrames - 1))
    else:
      frame = 1

    # TODO scale x according to directionIsLeft
    # TODO add arm and head
    self.get_node('Legs').frame = frame
