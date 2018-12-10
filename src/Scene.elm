module Scene exposing (..)

import Circle
import Dict exposing (Dict)
import Game exposing (..)
import Map exposing (Tile)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Vector4 as Vec4 exposing (Vec4, vec4)
import Obstacle
import Quad
import Set exposing (Set)
import WebGL exposing (Entity, Mesh, Shader)


-- Periodic functions


periodLinear : Float -> Float -> Float -> Float
periodLinear time phase period =
    let
        t =
            time + phase * period

        n =
            t / period |> floor |> toFloat
    in
    t / period - n


periodHarmonic : Float -> Float -> Float -> Float
periodHarmonic time phase period =
    2 * pi * periodLinear time phase period |> sin



-- Entities


type alias EntitiesArgs =
    { cameraToViewport : Mat4
    , time : Float
    , player : Game.Player
    }


entities : EntitiesArgs -> List Entity
entities { cameraToViewport, time, player } =
    let
        worldToViewport =
            cameraToViewport
                --|> Mat4.scale3 (1 / Map.worldSize) (1 / Map.worldSize) 1

        blockers =
            Map.tilemap
                |> Dict.toList
                |> List.map (obstacleToEntity worldToViewport)
                |> List.concat

        playerEntity =
            [ mob worldToViewport player.position (vec3 1 0 0)
            ]
    in
    List.concat
        [ blockers
        , playerEntity
        ]


mob : Mat4 -> Vec2 -> Vec3 -> Entity
mob worldToViewport position color =
    let
        { x, y } =
            Vec2.toRecord position

        entityToViewport =
            worldToViewport
                |> Mat4.translate3 x y 0
                |> Mat4.scale3 Game.playerSize.width Game.playerSize.height 1
    in
    Quad.entity entityToViewport color


dot : Mat4 -> Vec2 -> Float -> Vec3 -> Entity
dot worldToViewport position size color =
    let
        { x, y } =
            Vec2.toRecord position

        entityToViewport =
            worldToViewport
                |> Mat4.translate3 x y 0
                |> Mat4.scale3 size size 1
    in
    Circle.entity entityToViewport color


tileColor : Mat4 -> Tile -> Vec3 -> Entity
tileColor worldToViewport tile color =
    let
        { x, y } =
            tile
                |> Map.tileCenter
                |> Vec2.toRecord

        entityToViewport =
            worldToViewport
                |> Mat4.translate3 x y 0
    in
    Quad.entity entityToViewport color


obstacleToEntity : Mat4 -> ( ( Int, Int ), Char ) -> List Entity
obstacleToEntity worldToViewport ( ( x, y ), char ) =
    let
        blockers =
            Map.charToBlockers char

        anglesAndBlockers =
            [ ( .negativeDeltaY, 0 )
            , ( .positiveDeltaY, pi )
            , ( .positiveDeltaX, pi / 2 )
            , ( .negativeDeltaX, -pi / 2 )
            ]

        stuff ( getter, angle ) =
            if getter blockers then
                worldToViewport
                    |> Mat4.translate3 (toFloat x + 0.5) (toFloat y + 0.5) 0
                    |> Mat4.rotate angle (vec3 0 0 1)
                    |> Obstacle.entity
                    |> Just
            else
                Nothing
    in
    List.filterMap stuff anglesAndBlockers
