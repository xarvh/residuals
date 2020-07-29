extends Node2D


static func getAncestor(child, name):
    var parent = child.get_parent()

    if !parent:
      # TODO print only if debug mode is on
      print("no ancestor found with name ", name)
      return null

    if parent.get_name() == name:
        return parent
    else:
        return getAncestor(parent, name)


static func callAncestorMethod(child, methodName, args = []):
    var parent = child.get_parent()

    if !parent:
      # TODO print only if debug mode is on
      print("no ancestor found with method ", methodName)
      return null

    if parent.has_method(methodName):
        return parent.callv(methodName, args)
    else:
        return callAncestorMethod(parent, methodName, args)


static func callOnDescendants(node, methodName, args = []):
    var n = 0

    if node.has_method(methodName):
        node.callv(methodName, args)
        n += 1

    for child in node.get_children():
        n += callOnDescendants(child, methodName, args)

    return n


static func removeAllChildren(parent):
    for n in parent.get_children():
        parent.remove_child(n)
        n.queue_free()
