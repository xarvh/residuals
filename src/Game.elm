module Game exposing (..)

import Map
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import TileCollision.Normalized exposing (Size)


--


clampToRadius : Float -> Vec2 -> Vec2
clampToRadius radius v =
    let
        ll =
            Vec2.lengthSquared v
    in
    if ll <= radius * radius then
        v
    else
        Vec2.scale (radius / sqrt ll) v



--


baseAcceleration =
    0.4


maxSpeed =
    10


playerSize : Size
playerSize =
    { width = 0.5
    , height = 1
    }


tileSize =
    16



--


type alias Game =
    { player : Player
    , time : Float
    }


type alias Player =
    { position : Vec2
    , speed : Vec2
    }


playerInit : Player
playerInit =
    { position = vec2 0 5
    , speed = vec2 0 0
    }


playerThink : Float -> { x : Int, y : Int } -> Player -> Player
playerThink dt input player =
    let
        q = Debug.log "" input
        movementAcceleration =
            vec2 (toFloat input.x * baseAcceleration) (toFloat input.y * baseAcceleration)

        gravityAcceleration =
            vec2 0 (-baseAcceleration / 2)

        totalAcceleration =
            Vec2.add movementAcceleration gravityAcceleration

        speed =
            totalAcceleration
                |> Vec2.scale dt
                |> Vec2.add player.speed
                |> clampToRadius maxSpeed

        idealPosition =
            speed
                |> Vec2.scale dt
                |> Vec2.add player.position

        maybeCollision =
            TileCollision.Normalized.collide
                { hasBlockerAlong = Map.hasBlockerAlong
                , tileSize = tileSize
                , mobSize = playerSize
                , start = player.position
                , end = idealPosition
                }

        fixedPosition =
            case maybeCollision of
                Nothing ->
                    idealPosition

                Just collision ->
                    collision.fix
    in
    { player | position = fixedPosition, speed = speed }
