extends AnimationPlayer


onready var toolNode = get_parent().get_node('Legs/Torso+Head/Arm/HeldItem')


func _onSwingHit():
    Meta.callAncestorMethod(self, 'playerToolSwingHit')


func setHeldItem(itemId):

    Meta.removeAllChildren(toolNode)

    var item = Env.itemsById[itemId]
    if item.scene and item.use == Env.ItemUse.Swing:
        toolNode.add_child(item.scene.instance())
