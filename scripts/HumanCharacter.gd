extends AnimationPlayer


const meta = preload('res://scripts/meta.gd')


func _onSwingHit():
    meta.callAncestorMethod(self, "playerToolSwingHit")
