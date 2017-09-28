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
import Task
import Window
import WebGL


--

import Obstacle exposing (Obstacle)
import Primitives
import Viewport


-- Types


type alias Drag =
    { offset : Vec2
    , obstacle : Obstacle
    }


type alias Model =
    { obstacles : List Obstacle
    , maybeDrag : Maybe Drag
    , mousePosition : Vec2
    , window : Window.Size
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
            , window =
                { width = 100
                , height = 100
                }
            , mousePosition = vec2 0 0
            }

        cmd =
            Window.size |> Task.perform WindowResize
    in
        ( model, cmd )



-- viewport


windowSizeInGameCoordinates : Model -> ( Float, Float )
windowSizeInGameCoordinates model =
    let
        viewportRatio =
            toFloat model.window.width / toFloat model.window.height

        viewportH =
            2

        viewportW =
            viewportH * viewportRatio
    in
        ( viewportW, viewportH )


mouseToGameCoordinates : Model -> Mouse.Position -> Vec2
mouseToGameCoordinates model position =
    let
        -- window geometry
        ( wW, wH ) =
            ( toFloat model.window.width, toFloat model.window.height )

        ( mX, mY ) =
            ( toFloat position.x, toFloat position.y )

        -- viewport geometry
        ( vW, vH ) =
            windowSizeInGameCoordinates model

        x =
            vW * (mX / wW - 0.5)

        y =
            vH * ((wH / 2) - mY) / wH
    in
        vec2 x y



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


withObstacleUnderMouse : Model -> (Obstacle -> List Obstacle -> List Obstacle) -> Model
withObstacleUnderMouse model mutator =
    case closestObstacle model of
        Nothing ->
            model

        Just obstacle ->
            { model | obstacles = mutator obstacle model.obstacles }


rotateObstacle : Float -> Obstacle -> List Obstacle -> List Obstacle
rotateObstacle a obstacle list =
    List.Extra.replaceIf (\o -> o == obstacle) { obstacle | angle = obstacle.angle + a } list


duplicateObstacle : Obstacle -> List Obstacle -> List Obstacle
duplicateObstacle obstacle list =
    { obstacle | width = obstacle.width + 0.000001 } :: list


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
            updateDrag { model | mousePosition = Viewport.mouseToViewportCoordinates model.window position }

        WindowResize size ->
            { model | window = size }

        OnKeyboard code ->
            case Debug.log "" <| Char.fromCode code of
                'a' ->
                    withObstacleUnderMouse model (rotateObstacle (degrees 5))

                's' ->
                    withObstacleUnderMouse model (rotateObstacle (degrees -5))

                'd' ->
                    withObstacleUnderMouse model duplicateObstacle

                ' ' ->
                    let
                        q =
                            Debug.log "" model.obstacles
                    in
                        model

                _ ->
                    model



-- entities


entities : Model -> List WebGL.Entity
entities model =
    let
        viewMatrix =
            Viewport.worldToCameraMatrix model.window

        obstacles =
            List.map (Obstacle.render viewMatrix 0.3) model.obstacles

        drag =
            case model.maybeDrag of
                Nothing ->
                    []

                Just drag ->
                    [ Obstacle.render viewMatrix 0.7 drag.obstacle ]
    in
        [ obstacles
        , drag
        ]
            |> List.concat



-- view


view : Model -> Html Msg
view model =
    model
        |> entities
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
        [ Mouse.downs (always DragStart)
        , Mouse.ups (always DragStop)
        , Mouse.moves MouseMove
        , Window.resizes WindowResize
        , Keyboard.presses OnKeyboard
        ]



-- main


main =
    Html.program
        { init = init
        , update = \msg model -> ( update msg model, Cmd.none )
        , view = view
        , subscriptions = subscriptions
        }
