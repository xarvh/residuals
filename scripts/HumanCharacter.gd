extends AnimationPlayer


func _onSwingHit():
    Meta.callAncestorMethod(self, "playerToolSwingHit")
