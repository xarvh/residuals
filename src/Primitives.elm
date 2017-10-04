module Primitives exposing (..)

import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
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


triangleVertices : List Vec3
triangleVertices =
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
    [ a, b, c ]


triangleMesh : Mesh MeshVertex
triangleMesh =
    triangleVertices
        |> List.map MeshVertex
        |> WebGL.triangleFan


triangle : Uniforms -> WebGL.Entity
triangle uniforms =
    WebGL.entity vertexShader fragmentShader triangleMesh uniforms



-- Right Triangle


rightTriangleVertices : List Vec3
rightTriangleVertices =
    let
        top =
            0.5

        bottom =
            -top

        right =
            0.5

        left =
            -right

        a =
            vec3 left bottom 0

        b =
            vec3 left top 0

        c =
            vec3 right bottom 0
    in
    [ a, b, c ]


rightTriangleMesh : Mesh MeshVertex
rightTriangleMesh =
    rightTriangleVertices
        |> List.map MeshVertex
        |> WebGL.triangleFan


rightTriangle : Uniforms -> WebGL.Entity
rightTriangle uniforms =
    WebGL.entity vertexShader fragmentShader rightTriangleMesh uniforms



-- Quad


quadVertices : List Vec3
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
            vec3 left top 0

        b =
            vec3 right top 0

        c =
            vec3 right bottom 0

        d =
            vec3 left bottom 0
    in
    [ a, b, c, d ]


quadMesh : Mesh MeshVertex
quadMesh =
    quadVertices
        |> List.map MeshVertex
        |> WebGL.triangleFan


quad : Uniforms -> WebGL.Entity
quad uniforms =
    WebGL.entity vertexShader fragmentShader quadMesh uniforms



-- Icosagon


icosagonVertices : List Vec3
icosagonVertices =
    let
        n =
            20

        half =
            0.5

        indexToVertex index =
            let
                angle =
                    turns 1 * toFloat index / n
            in
            vec3 (half * cos angle) (half * sin angle) 0

        perimeter =
            -- range is inclusive, so the first point will be repeated
            List.range 0 n |> List.map indexToVertex

        fan =
            vec3 0 0 0 :: perimeter
    in
    fan


icosagonMesh : Mesh MeshVertex
icosagonMesh =
    icosagonVertices
        |> List.map MeshVertex
        |> WebGL.triangleFan


icosagon : Uniforms -> WebGL.Entity
icosagon uniforms =
    WebGL.entity vertexShader fragmentShader icosagonMesh uniforms
