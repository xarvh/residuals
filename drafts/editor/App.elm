module App exposing (..)

import Char
import Html exposing (Html)
import Html.Attributes
import Keyboard
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Mouse
import Primitives
import Task
import Window
import WebGL


-- Types


type alias Obstacle =
    { center : Vec2
    , width : Float
    , height : Float
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
    | OnKeyboard Keyboard.KeyCode



-- init


init : ( Model, Cmd Msg )
init =
    let
        model =
            { obstacles =
                [ { center = vec2 0 0
                  , angle = 0
                  , width = 0.5
                  , height = 0.1
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


closestObstacle : Model -> Maybe Obstacle
closestObstacle model =
    let
        pairWithSquaredDistance o =
            ( o, Vec2.distanceSquared o.center model.mousePosition )

        isCloseEnough ( obstacle, squaredDistance ) =
            if squaredDistance <= obstacle.width * obstacle.height then
                Just obstacle
            else
                Nothing
    in
        model.obstacles
            |> List.map pairWithSquaredDistance
            |> List.Extra.minimumBy Tuple.second
            |> Maybe.andThen isCloseEnough


updateRotate : Float -> Model -> Model
updateRotate a model =
    case Debug.log "--" <| closestObstacle model of
        Nothing ->
            model

        Just obstacle ->
            { model
                | obstacles =
                    model.obstacles
                        |> List.Extra.replaceIf (\o -> o == obstacle) { obstacle | angle = obstacle.angle + a }
            }


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
                    { oldObstacle | center = model.mousePosition }

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
                    case closestObstacle model of
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
                    ( 2, 2 )

                x =
                    vW * (wX - wW / 2) / wW

                y =
                    vH * (-wY + wH / 2) / wH
            in
                updateDrag { model | mousePosition = vec2 x y }

        WindowResize size ->
            { model | windowSize = Debug.log "" size }

        OnKeyboard code ->
            case Char.fromCode code of
                'A' ->
                    updateRotate (degrees 5) model

                'S' ->
                    updateRotate (degrees -5) model

                ' ' ->
                    let
                        q =
                            Debug.log "" model.obstacles
                    in
                        model
                _ ->
                  model



-- view


renderObstacle : Float -> Obstacle -> WebGL.Entity
renderObstacle color obstacle =
    let
        uniforms =
            { color = color
            , transform =
                Mat4.identity
                    |> Mat4.translate3 (Vec2.getX obstacle.center) (Vec2.getY obstacle.center) 0
                    |> Mat4.scale3 obstacle.width obstacle.height 1
                    |> Mat4.rotate obstacle.angle (vec3 0 0 1)
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
                , Html.Attributes.style
                    [ ( "width", "99vw" )
                    , ( "height", "99vh" )
                    ]
                ]



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.downs (always DragStart)
        , Mouse.ups (always DragStop)
        , Mouse.moves MouseMove
        , Window.resizes WindowResize
        , Keyboard.ups OnKeyboard
        ]



-- main


main =
    Html.program
        { init = init
        , update = \msg model -> ( update msg model, Cmd.none )
        , view = view
        , subscriptions = subscriptions
        }
