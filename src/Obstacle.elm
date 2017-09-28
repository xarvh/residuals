module Obstacle exposing (..)

import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Matrix4 as Mat4 exposing (Mat4)
import WebGL


--

import Primitives


-- types


type alias Obstacle =
    { center : Vec2
    , width : Float
    , height : Float
    , angle : Float
    }


render : Mat4 -> Float -> Obstacle -> WebGL.Entity
render viewMatrix color obstacle =
    let
        uniforms =
            { color = color
            , transform =
                Mat4.identity
                    |> Mat4.translate3 (Vec2.getX obstacle.center) (Vec2.getY obstacle.center) 0
                    |> Mat4.rotate obstacle.angle (vec3 0 0 1)
                    |> Mat4.scale3 obstacle.width obstacle.height 1
                    |> Mat4.mul viewMatrix
            }
    in
        Primitives.quad uniforms
