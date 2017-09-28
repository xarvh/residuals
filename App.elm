module App exposing (..)

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


--

import Level0
import Obstacle exposing (Obstacle)
import Primitives
import Viewport


-- Types


type alias Model =
    { obstacles : List Obstacle
    , window : Window.Size
    , mousePosition : Vec2
    , mouseButton : Bool
    }


type Msg
    = MouseMove Mouse.Position
    | MouseButton Bool
    | WindowResize Window.Size



-- init


init : ( Model, Cmd Msg )
init =
    let
        model =
            { obstacles = Level0.obstacles
            , window = { width = 100, height = 100 }
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
            { model | mousePosition = Viewport.mouseToViewportCoordinates model.window position }

        MouseButton isDown ->
            { model | mouseButton = isDown }

        WindowResize size ->
            { model | window = size }



-- view


view : Model -> Html Msg
view model =
    let
        viewMatrix =
            Viewport.worldToCameraMatrix model.window

        obstacles =
            List.map (Obstacle.render viewMatrix 0.3) model.obstacles
    in
        [ obstacles
        ]
            |> List.concat
            |> WebGL.toHtml
                [ Html.Attributes.width model.window.width
                , Html.Attributes.height model.window.height
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
