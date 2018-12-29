module Game exposing (..)

import Map
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import TileCollision exposing (CollisionTile, Direction(..), Size)
import Vector exposing (Vector)


baseAcceleration =
    4


maxSpeed =
    100


playerSize : Size
playerSize =
    { halfWidth = 4
    , halfHeight = 8
    }


tileSize =
    16



--


intToFloat : Vector -> Vec2
intToFloat { x, y } =
    vec2 (toFloat x) (toFloat y)


floatToInt : Vec2 -> Vector
floatToInt v =
    Vector (Vec2.getX v |> round) (Vec2.getY v |> round)


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
    { position = vec2 0 50
    , speed = vec2 0 0
    }


playerThink : Float -> { x : Int, y : Int } -> Player -> Player
playerThink dt input player =
    let
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
                |> 


        maybeCollision =
            TileCollision.collide
                { hasBlockerAlong = Map.hasBlockerAlong
                , tileSize = tileSize
                , mobSize = playerSize
                , start = floatToInt player.position
                , end = floatToInt idealPosition
                }

        ( fixedPosition, fixedSpeed ) =
            case maybeCollision of
                Nothing ->
                    ( idealPosition, speed )

                Just collision ->
                    ( collision.fix, fixSpeed collision.tiles speed )

        finalPosition
        initial = Vec2.toRecord
        fixed = Vec2.toRecord fixedPosition

        finalX =
          if 


        finalX =
          if abs (
        finalPosition =
          if Vec2.distanceSquared fixedPosition
        q =
            Debug.log "dp" (Vector.sub fixedPosition player.position)
    in
    { player | position = fixedPosition, speed = fixedSpeed }


fixSpeed : List CollisionTile -> Vec2 -> Vec2
fixSpeed tiles speed =
    let
        sp tile ( x, y ) =
            case Debug.log "speedfix" tile.d of
                PositiveDeltaX ->
                    ( min 0 x, y )

                NegativeDeltaX ->
                    ( max 0 x, y )

                PositiveDeltaY ->
                    ( x, min 0 y )

                NegativeDeltaY ->
                    ( x, max 0 y )

        ( xx, yy ) =
            List.foldl sp ( Vec2.getX speed, Vec2.getY speed ) tiles
    in
    vec2 xx yy
