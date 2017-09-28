module App exposing (..)

import Html exposing (Html)
import Html.Attributes
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Matrix4 as Mat4 exposing (Mat4)
import WebGL


--

import Input
import Level0
import Obstacle exposing (Obstacle)
import Primitives
import Viewport


-- Types


type alias Model =
    { obstacles : List Obstacle
    , viewport : Viewport.Model
    , input : Input.Model
    }


type Msg
    = InputMsg Input.Msg
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
            }

        cmd =
            viewportCmd |> Cmd.map ViewportMsg
    in
        ( model, cmd )



-- update


update : Msg -> Model -> Model
update msg model =
    case msg of
        InputMsg msg ->
            { model | input = Input.update msg model.input }

        ViewportMsg msg ->
            { model | viewport = Viewport.update msg model.viewport }



-- view


view : Model -> Html Msg
view model =
    let
        viewMatrix =
            Viewport.worldToCameraMatrix model.viewport

        obstacles =
            List.map (Obstacle.render viewMatrix 0.3) model.obstacles
    in
        [ obstacles
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
        ]



-- main


main =
    Html.program
        { init = init
        , update = \msg model -> ( update msg model, Cmd.none )
        , view = view
        , subscriptions = subscriptions
        }
