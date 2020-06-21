extends Object


var size
var items


func _init(size):
    self.size = size

    self.items = []
    for i in size:
        self.items.append(null)


func insertInFirstEmptySlot(item):
    var index = items.find(null)

    if index != -1:
        items[index] = item

    return index
