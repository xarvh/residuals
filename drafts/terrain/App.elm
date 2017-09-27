module App exposing (..)

import Html.Attributes
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Random
import WebGL exposing (Mesh, Shader)


type alias Triangle =
    { color : Float
    , transform : Mat4
    }



-- render


type alias MeshVertex =
    { position : Vec3
    }


mesh =
    let
        top =
            1

        bottom =
            -(sin (degrees 30))

        center =
            0

        right =
            cos (degrees 30)

        left =
            -right

        a =
            vec3 top center 0

        b =
            vec3 bottom right 0

        c =
            vec3 bottom left 0
    in
        [ ( MeshVertex a, MeshVertex b, MeshVertex c )
        ]
            |> WebGL.triangles


vertexShader : Shader MeshVertex Triangle {}
vertexShader =
    [glsl|
        attribute vec3 position;

        uniform mat4 transform;

        void main () {
            gl_Position = transform * vec4(position, 1.0);
        }

    |]


fragmentShader : Shader {} Triangle {}
fragmentShader =
    [glsl|
        precision mediump float;
        uniform float color;

        void main() {
            gl_FragColor = vec4(color, color, color, 1);
        }
    |]


renderTriangle : Triangle -> WebGL.Entity
renderTriangle triangle =
    WebGL.entity vertexShader fragmentShader mesh triangle



-- generator


makeTriangle : Float -> Vec2 -> Float -> Float -> Float -> Triangle
makeTriangle color position rotation skew s =
    let
        height =
            -(Vec2.getY position)

        size =
            s * (2 + height) / 2
    in
        { color = (height + color) / 2
        , transform =
            Mat4.identity
                |> Mat4.translate3 (Vec2.getX position) (Vec2.getY position) 0
                |> Mat4.rotate rotation (vec3 0 0 1)
                |> Mat4.scale3 (size * skew) (size / skew) 1
        }


makeSkew : Bool -> Float -> Float
makeSkew isVertical scale =
    if isVertical then
        scale
    else
        1 / scale


triangleGenerator : Random.Generator Triangle
triangleGenerator =
    Random.map5 makeTriangle
        -- color
        (Random.float 0 0.2)
        -- position
        (Random.map2 vec2 (Random.float -1 1) (Random.float -1 0))
        -- rotation
        (Random.float 0 (turns 1))
        -- skew
        (Random.map2 makeSkew Random.bool (Random.float 1 1.5))
        -- size
        (Random.float 0.01 0.05)



-- main


triangles =
    Random.step (Random.list 8000 triangleGenerator) (Random.initialSeed 0)
        |> Tuple.first
        |> List.map renderTriangle


main =
    WebGL.toHtml
        [ Html.Attributes.width 1000
        , Html.Attributes.height 700
        ]
        triangles
