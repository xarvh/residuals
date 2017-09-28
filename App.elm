module App exposing (..)

import Primitives
import Html exposing (Html)
import Html.Attributes
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Mouse
import Task
import Window
import WebGL


-- Types


type alias Obstacle =
    { c : Vec2
    , w : Float
    , h : Float
    , angle : Float
    }


type alias Model =
    { obstacles : List Obstacle
    , windowSize : Window.Size
    , mousePosition : Vec2
    , mouseButton : Bool
    }


type Msg
    = MouseMove Mouse.Position
    | MouseButton Bool
    | WindowResize Window.Size



-- init


obs =
    [ { angle = turns 0.00, w = 0.5, h = 0.1, c = vec2 -0.5 0 }
    , { angle = turns 0.25, w = 0.5, h = 0.1, c = vec2 0.5 0.25 }
--     , { angle = turns 0.00, w = 0.5, h = 0.1, c = vec2 0 0 }
--     , { angle = turns 0.00, w = 0.5, h = 0.1, c = vec2 0 0 }
    ]


init : ( Model, Cmd Msg )
init =
    let
        model =
            { obstacles = obs
            , windowSize = { width = 100, height = 100 }
            , mousePosition = vec2 0 0
            , mouseButton = False
            }

        cmd =
            Window.size |> Task.perform WindowResize
    in
        ( model, cmd )



-- update


update : Msg -> Model -> Model
update msg model =
    case msg of
        MouseMove position ->
            let
                -- window geometry
                ( wW, wH ) =
                    ( toFloat model.windowSize.width, toFloat model.windowSize.height )

                ( wX, wY ) =
                    ( toFloat position.x, toFloat position.y )

                -- viewport geometry
                ( vW, vH ) =
                    ( 2, 2 )

                x =
                    vW * (wX - wW / 2) / wW

                y =
                    vH * (-wY + wH / 2) / wH
            in
                { model | mousePosition = vec2 x y }

        MouseButton isDown ->
            { model | mouseButton = isDown }

        WindowResize size ->
            { model | windowSize = Debug.log "" size }



-- view


renderObstacle : Float -> Obstacle -> WebGL.Entity
renderObstacle color obstacle =
    let
        uniforms =
            { color = color
            , transform =
                Mat4.identity
                    |> Mat4.translate3 (Vec2.getX obstacle.c) (Vec2.getY obstacle.c) 0
                    |> Mat4.rotate obstacle.angle (vec3 0 0 1)
                    |> Mat4.scale3 obstacle.w obstacle.h 1
            }
    in
        Primitives.quad uniforms


view : Model -> Html Msg
view model =
    let
        obstacles =
            List.map (renderObstacle 0.3) model.obstacles
    in
        [ obstacles
        ]
            |> List.concat
            |> WebGL.toHtml
                [ Html.Attributes.width model.windowSize.width
                , Html.Attributes.height model.windowSize.height
                , Html.Attributes.style
                    [ ( "width", "99vw" )
                    , ( "height", "99vh" )
                    ]
                ]



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.downs (\_ -> MouseButton True)
        , Mouse.ups (\_ -> MouseButton False)
        , Mouse.moves MouseMove
        , Window.resizes WindowResize
        ]



-- main


main =
    Html.program
        { init = init
        , update = \msg model -> ( update msg model, Cmd.none )
        , view = view
        , subscriptions = subscriptions
        }
