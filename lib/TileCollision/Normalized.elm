module TileCollision.Normalized
    exposing
        ( Args
        , BlockerDirections
        , Collision
        , CollisionTile
        , Size
        , collide
        )

import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import TileCollision


type alias BlockerDirections a =
    TileCollision.BlockerDirections a


type alias CollisionTile =
    TileCollision.CollisionTile


type alias Args =
    { hasBlockerAlong : BlockerDirections (Int -> Int -> Bool)
    , tileSize : Int
    , mobSize : Size
    , start : Vec2
    , end : Vec2
    }


type alias Collision =
    { point : Vec2
    , fix : Vec2
    , tiles : List CollisionTile
    }


type alias Size =
    { width : Float
    , height : Float
    }


collide : Args -> Maybe Collision
collide args =
    args
        |> mapArgs
        |> TileCollision.collide
        |> Maybe.map (mapCollision args.tileSize)


mapArgs : Args -> TileCollision.Args
mapArgs { hasBlockerAlong, tileSize, mobSize, start, end } =
    { hasBlockerAlong = hasBlockerAlong
    , tileSize = tileSize
    , mobSize =
        { halfWidth = mobSize.width * toFloat tileSize / 2 |> ceiling
        , halfHeight = mobSize.height * toFloat tileSize / 2 |> ceiling
        }
    , start = vec2ToVector tileSize start
    , end = vec2ToVector tileSize end
    }


vec2ToVector : Int -> Vec2 -> TileCollision.Vector
vec2ToVector tileSize v =
    { x = Vec2.getX v * toFloat tileSize |> round
    , y = Vec2.getY v * toFloat tileSize |> round
    }


mapCollision : Int -> TileCollision.Collision -> Collision
mapCollision tileSize { point, fix, tiles } =
    { point = vectorToVec2 tileSize point
    , fix = vectorToVec2 tileSize fix
    , tiles = tiles
    }


vectorToVec2 : Int -> TileCollision.Vector -> Vec2
vectorToVec2 tileSize { x, y } =
    vec2
        (toFloat x / toFloat tileSize)
        (toFloat y / toFloat tileSize)
