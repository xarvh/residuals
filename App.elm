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


type alias Drag =
    { offset : Vec2
    , obstacle : Obstacle
    }


type alias Model =
    { obstacles : List Obstacle
    , maybeDrag : Maybe Drag
    , windowSize : Window.Size
    , mousePosition : Vec2
    }


type Msg
    = DragStart
    | DragStop
    | MouseMove Mouse.Position
    | WindowResize Window.Size



-- init


init : ( Model, Cmd Msg )
init =
    let
        model =
            { obstacles =
                [ { c = vec2 0 0
                  , angle = 0
                  , w = 0.5
                  , h = 0.1
                  }
                ]
            , maybeDrag = Nothing
            , windowSize = { width = 100, height = 100 }
            , mousePosition = vec2 0 0
            }

        cmd =
            Window.size |> Task.perform WindowResize
    in
        ( model, cmd )



-- update


updateDrag : Model -> Model
updateDrag model =
    case model.maybeDrag of
        Nothing ->
            model

        Just drag ->
            let
                oldObstacle =
                    drag.obstacle

                newObstacle =
                    { oldObstacle | c = model.mousePosition }

                newDrag =
                    { drag | obstacle = newObstacle }
            in
                { model | maybeDrag = Just newDrag }


update : Msg -> Model -> Model
update msg model =
    case msg of
        DragStart ->
            case model.maybeDrag of
                Just _ ->
                    model

                Nothing ->
                    let
                        maybeObstacle =
                            model.obstacles
                                |> List.map (\o -> ( o, Vec2.distance o.c model.mousePosition ))
                                |> List.Extra.minimumBy Tuple.second
                                |> Maybe.map Tuple.first
                    in
                        case maybeObstacle of
                            Nothing ->
                                model

                            Just obstacle ->
                                let
                                    drag =
                                        { obstacle = obstacle
                                        , offset = vec2 0 0
                                        }

                                    obstacles =
                                        model.obstacles
                                            |> List.filter (\o -> o /= obstacle)
                                in
                                    { model | maybeDrag = Just drag, obstacles = obstacles }

        DragStop ->
            case model.maybeDrag of
                Nothing ->
                    model

                Just drag ->
                    { model | maybeDrag = Nothing, obstacles = drag.obstacle :: model.obstacles }

        MouseMove position ->
            let
                -- window geometry
                ( wW, wH ) =
                    ( toFloat model.windowSize.width, toFloat model.windowSize.height )

                ( wX, wY ) =
                    ( toFloat position.x, toFloat position.y )

                -- viewport geometry
                ( vW, vH ) =
                    ( 1, 1 )

                x =
                    vW * (wX - wW / 2) / wW

                y =
                    vH * (-wY + wH / 2) / wH
            in
                updateDrag { model | mousePosition = vec2 x y }

        WindowResize size ->
            { model | windowSize = size }



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

        drag =
            case model.maybeDrag of
                Nothing ->
                    []

                Just drag ->
                    [ renderObstacle 0.7 drag.obstacle ]
    in
        [ obstacles
        , drag
        ]
            |> List.concat
            |> WebGL.toHtml
                [ Html.Attributes.width model.windowSize.width
                , Html.Attributes.height model.windowSize.height
                ]



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.downs (always DragStart)
        , Mouse.ups (always DragStop)
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
