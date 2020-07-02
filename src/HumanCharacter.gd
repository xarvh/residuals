extends AnimationPlayer


onready var toolNode = get_parent().get_node('Legs/Torso+Head/Arm/HeldItem')


func _onSwingHit():
    Meta.callAncestorMethod(self, 'playerToolSwingHit')


func setHeldItem(texture):
    toolNode.texture = texture
