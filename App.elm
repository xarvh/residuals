module App exposing (..)

import Primitives
import Html.Attributes
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Matrix4 as Mat4 exposing (Mat4)
import WebGL


--


type alias Obstacle =
    { cX : Float
    , cY : Float
    , w : Float
    , h : Float
    , angle : Float
    }



-- render


renderObstacle : Obstacle -> WebGL.Entity
renderObstacle obstacle =
    let
        uniforms =
            { color = 0.7
            , transform =
                Mat4.identity
                    |> Mat4.translate3 obstacle.cX obstacle.cY 0
                    |> Mat4.rotate obstacle.angle (vec3 0 0 1)
                    |> Mat4.scale3 obstacle.w obstacle.h 1
            }
    in
        Primitives.quad uniforms



-- main


obstacles =
    [ { cX = 0
      , cY = 0
      , angle = 0
      , w = 0.5
      , h = 0.1
      }
    ]


main =
    WebGL.toHtml
        [ Html.Attributes.width 1000
        , Html.Attributes.height 700
        ]
        (List.map renderObstacle obstacles)
