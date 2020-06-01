extends Sprite


const maxBounceTime = 0.5
const maxBounceAmplitude = 0.005 * PI
const bounceSpeed = 10 * PI


onready var bounceTime = 0
onready var trunk = get_node('Trunk')


func _ready():
    pass


func _process(dt):
    if bounceTime > 0:
      bounceTime -= dt
      if trunk:
          trunk.rotation = maxBounceAmplitude * (bounceTime / maxBounceTime) * sin(bounceTime * bounceSpeed)


func onHitByTool(toolName, toolPower, player):
    if trunk:
        bounceTime = maxBounceTime
    else:
        pass
