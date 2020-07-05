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

    for child in node.get_children():

        if child.has_method(methodName):
            child.callv(methodName, args)
            n += 1

        n += callOnDescendants(child, methodName, args)

    return n
