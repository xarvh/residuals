module App exposing (..)

import AnimationFrame
import Html exposing (Html)
import Html.Attributes
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Matrix4 as Mat4 exposing (Mat4)
import WebGL
import Time exposing (Time)


--

import Input
import Level0
import Obstacle exposing (Obstacle)
import Primitives
import Viewport


-- Types


type alias Hero =
    { position : Vec2
    }


type alias Model =
    { obstacles : List Obstacle
    , viewport : Viewport.Model
    , input : Input.Model
    , hero : Hero
    }


type Msg
    = AnimationFrame Time
    | InputMsg Input.Msg
    | ViewportMsg Viewport.Msg



-- init


init : ( Model, Cmd Msg )
init =
    let
        ( viewport, viewportCmd ) =
            Viewport.init

        model =
            { obstacles = Level0.obstacles
            , viewport = viewport
            , input = Input.init
            , hero =
                { position = vec2 0 0
                }
            }

        cmd =
            viewportCmd |> Cmd.map ViewportMsg
    in
        ( model, cmd )



-- update


updateHero : Time -> Input.State -> List Obstacle -> Hero -> Hero
updateHero dt inputState obstacles hero =
    hero


updateFrame : Time -> Model -> Model
updateFrame dt model =
    let
        transformMouseCoordinates =
            Viewport.mouseToViewportCoordinates model.viewport

        inputState =
            Input.keyboardAndMouseInputState model.input transformMouseCoordinates
    in
        { model | hero = updateHero dt inputState model.obstacles model.hero }


update : Msg -> Model -> Model
update msg model =
    case msg of
        AnimationFrame dt ->
            updateFrame dt model

        InputMsg msg ->
            { model | input = Input.update msg model.input }

        ViewportMsg msg ->
            { model | viewport = Viewport.update msg model.viewport }



-- view

renderHero : Mat4 -> Hero -> WebGL.Entity
renderHero viewMatrix hero =
    let
        size =
          0.04

        uniforms =
            { color = 0
            , transform =
                Mat4.identity
                    |> Mat4.translate3 (Vec2.getX hero.position) (Vec2.getY hero.position) 0
                    |> Mat4.rotate 0 (vec3 0 0 1)
                    |> Mat4.scale3 size size 1
                    |> Mat4.mul viewMatrix
            }
    in
        Primitives.icosagon uniforms




view : Model -> Html Msg
view model =
    let
        viewMatrix =
            Viewport.worldToCameraMatrix model.viewport

        hero =
          renderHero viewMatrix model.hero

        obstacles =
            List.map (Obstacle.render viewMatrix 0.3) model.obstacles
    in
        [ obstacles
        , [hero]
        ]
            |> List.concat
            |> WebGL.toHtml
                [ Html.Attributes.width model.viewport.width
                , Html.Attributes.height model.viewport.height
                , Html.Attributes.style
                    [ ( "width", "99vw" )
                    , ( "height", "99vh" )
                    ]
                ]



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Input.subscriptions model.input |> Sub.map InputMsg
        , Viewport.subscriptions model.viewport |> Sub.map ViewportMsg
        , AnimationFrame.diffs AnimationFrame
        ]



-- main


main =
    Html.program
        { init = init
        , update = \msg model -> ( update msg model, Cmd.none )
        , view = view
        , subscriptions = subscriptions
        }
