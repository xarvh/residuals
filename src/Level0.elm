module Level0 exposing (..)

import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Obstacle exposing (Obstacle)


obstacles : List Obstacle
obstacles =
    [ { center = vec2 0.3194192349910736 0.2704174220561981, angle = 0, width = 0.5000030000000001, height = 0.1 }
    , { center = vec2 -0.3520871102809906 -0.05263157933950424, angle = 0, width = 0.5000020000000001, height = 0.1 }
    , { center = vec2 -0.6678766012191772 -0.44464609026908875, angle = 0, width = 0.5, height = 0.1 }
    , { center = vec2 0.7549909353256226 -0.30671507120132446, angle = 0.6981317007977318, width = 0.5000020000000001, height = 0.1 }
    , { center = vec2 0.3266787528991699 -0.44464609026908875, angle = 0, width = 0.500001, height = 0.1 }
    , { center = vec2 -0.17059890925884247 -0.44464609026908875, angle = 0, width = 0.500001, height = 0.1 }
    , { center = vec2 0.020253164693713188 0.29620254039764404, angle = 0.34906585039886584, width = 0.5000020000000001, height = 0.1 }
    , { center = vec2 0.048101264983415604 0.5721518993377686, angle = -0.7853981633974484, width = 0.5000030000000001, height = 0.1 }
    ]
