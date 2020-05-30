
# TODO varargs
static func callAncestorMethod(child, methodName):
    var parent = child.get_parent()

    if !parent:
      # TODO print only if debug mode is on
      print("no ancestor found with method ", methodName)
      return null

    if parent.has_method(methodName):
        return parent.call(methodName)
    else:
        return callAncestorMethod(parent, methodName)
