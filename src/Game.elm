module Game exposing (..)

import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import TileCollision.Normalized exposing (Size)


type alias Game =
    { player : Player
    , time : Float
    }


type alias Player =
    { position : Vec2
    , speed : Vec2
    }


playerSize : Size
playerSize =
    { width = 0.5
    , height = 1
    }


playerInit : Player
playerInit =
    { position = vec2 0 5
    , speed = vec2 0 0
    }


playerThink : Float -> Player -> Player
playerThink dt player =
    player
