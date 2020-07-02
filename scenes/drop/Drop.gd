extends Sprite


#
# Config
#
const maxSpeed = 50
const friction = 7
const collectionDistance = 4
const vacuumSpeed = 30


#
# Init
#
onready var player = null
onready var type = Env.Item.Wood
onready var velocity = Vector2(rndSpeed(), rndSpeed())


#
#
#
func _process(dt):
    if !player:
      var acceleration = -friction * velocity
      velocity += dt * acceleration

    else:
      var dp = player.position - position

      if dp.length() < collectionDistance:
          player.collectItem(type)
          queue_free()
      else:
        velocity = dp.normalized() * vacuumSpeed

    position += dt * velocity


func _on_Area2D_area_entered(body):
    # TODO what if the player backpack is full?
    player = Meta.getAncestor(body, 'Player')


#
#
#
static func rndSpeed():
    return Env.rng.randf_range(-maxSpeed, maxSpeed)
