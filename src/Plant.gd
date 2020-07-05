extends Sprite


onready var growth = 0


func oneDayPasses():
    growth += 1

    # Using `frame` as growth stage
    match frame:
        0:
          if growth >= 1:
            z_index = 0
            frame += 1
            growth = 0

        1:
          if growth >= 2:
            frame += 1
            growth = 0

        2:
          if growth >= 4:
            frame += 1
            growth = 0

        3:
          if growth >= 4:
            frame += 1
            growth = 0

        4:
          if growth >= 1:
            frame += 1
            growth = 0
            # TODO: make harvestable
