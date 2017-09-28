module Primitives exposing (..)

import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Matrix4 as Mat4 exposing (Mat4)
import WebGL exposing (Mesh, Shader)


-- Shaders


type alias MeshVertex =
    { position : Vec3
    }


type alias Uniforms =
    { transform : Mat4
    , color : Float
    }


vertexShader : Shader MeshVertex Uniforms {}
vertexShader =
    [glsl|
        attribute vec3 position;

        uniform mat4 transform;

        void main () {
            gl_Position = transform * vec4(position, 1.0);
        }

    |]


fragmentShader : Shader {} Uniforms {}
fragmentShader =
    [glsl|
        precision mediump float;
        uniform float color;

        void main() {
            gl_FragColor = vec4(color, color, color, 1);
        }
    |]



-- Tris


trisVertices : List MeshVertex
trisVertices =
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
            vec3 center top 0

        b =
            vec3 right bottom 0

        c =
            vec3 left bottom 0
    in
        [ MeshVertex a
        , MeshVertex b
        , MeshVertex c
        ]


trisMesh : Mesh MeshVertex
trisMesh =
    WebGL.triangleFan trisVertices


tris : Uniforms -> WebGL.Entity
tris uniforms =
    WebGL.entity vertexShader fragmentShader trisMesh uniforms



-- Quad


quadVertices : List MeshVertex
quadVertices =
    let
        half =
            0.5

        top =
            half

        bottom =
            -half

        right =
            half

        left =
            -half

        a =
            vec3 top left 0

        b =
            vec3 top right 0

        c =
            vec3 bottom right 0

        d =
            vec3 bottom left 0
    in
        [ MeshVertex a
        , MeshVertex b
        , MeshVertex c
        , MeshVertex d
        ]


quadMesh : Mesh MeshVertex
quadMesh =
    WebGL.triangleFan quadVertices


quad : Uniforms -> WebGL.Entity
quad uniforms =
    WebGL.entity vertexShader fragmentShader quadMesh uniforms
