extends Sprite


#
# Config
#
const maxSpeed = 50
const friction = 7


#
# Init
#
onready var type = Env.Item.Wood
onready var velocity = Vector2(rndSpeed(), rndSpeed())


#
#
#
func _process(delta):
    var acceleration = -friction * velocity
    velocity += delta * acceleration
    position += delta * velocity


#
#
#
static func rndSpeed():
    return Env.rng.randf_range(-maxSpeed, maxSpeed)
