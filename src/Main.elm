module Main exposing (..)

import Browser
import Browser.Events
import Game
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Json.Decode exposing (Decoder)
import Keyboard
import Keyboard.Arrows
import Map
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Scene
import Vector exposing (Vector)
import Time exposing (Posix)
import Viewport exposing (PixelPosition, PixelSize)
import WebGL


-- Types


type alias Flags =
    {}


type alias Model =
    { viewportSize : PixelSize
    , currentTimeInSeconds : Float
    , player : Game.Player
    , keys : List Keyboard.Key
    , pause : Bool
    }


type Msg
    = OnResize PixelSize
    | OnAnimationFrame Float
    | OnKey Keyboard.Msg



-- Init


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        model =
            { viewportSize =
                { width = 640
                , height = 480
                }
            , currentTimeInSeconds = 0
            , player = Game.playerInit
            , keys = []
            , pause = False
            }

        cmd =
            Viewport.getWindowSize OnResize
    in
    ( model, cmd )



-- Update


noCmd : Model -> ( Model, Cmd Msg )
noCmd model =
    ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnResize size ->
            noCmd { model | viewportSize = size }

        OnKey keymsg ->
            let
                ( keys, maybeKeyChange ) =
                    Keyboard.updateWithKeyChange Keyboard.anyKey keymsg model.keys
            in
            { model | keys = keys }
                |> updateOnKeyChange maybeKeyChange

        OnAnimationFrame dtInMilliseconds ->
            let
                -- dt is in seconds
                dt =
                    dtInMilliseconds / 1000

                player =
                    Game.playerThink dt (Keyboard.Arrows.arrows model.keys) model.player
            in
            noCmd
                { model
                    | currentTimeInSeconds = model.currentTimeInSeconds + dt
                    , player = player
                }


updateOnKeyChange : Maybe Keyboard.KeyChange -> Model -> ( Model, Cmd Msg )
updateOnKeyChange maybeKeyChange model =
    case maybeKeyChange of
        Just (Keyboard.KeyUp key) ->
            case Debug.log "KEY" key of
                Keyboard.Enter ->
                    let
                        ( m, c ) =
                            update (OnAnimationFrame 20) model

                        q =
                            Debug.log "player" ( model.player.speed, m.player.speed )
                    in
                    ( m, c )

                Keyboard.Character "p" ->
                    noCmd { model | pause = not model.pause }

                _ ->
                    noCmd model

        _ ->
            noCmd model



-- View


view : Model -> Browser.Document Msg
view model =
    let
        entities =
            Scene.entities
                { cameraToViewport = Viewport.worldToPixelTransform model.viewportSize (Game.tileSize * 10)
                , player = model.player
                , time = model.currentTimeInSeconds
                }
    in
    { title = "Residuals of Humanity"
    , body =
        [ Viewport.toHtml model.viewportSize entities
        , Html.node "style" [] [ Html.text "body { margin: 0; }" ]
        ]
    }



-- Subscriptions


mousePositionDecoder : Decoder PixelPosition
mousePositionDecoder =
    Json.Decode.map2 (\x y -> { left = x, top = y })
        (Json.Decode.field "clientX" Json.Decode.int)
        (Json.Decode.field "clientY" Json.Decode.int)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Viewport.onWindowResize OnResize
        , if model.pause then
            Sub.none
          else
            Browser.Events.onAnimationFrameDelta OnAnimationFrame
        , Keyboard.subscriptions |> Sub.map OnKey

        --, Browser.Events.onMouseMove mousePositionDecoder |> Sub.map OnMouseMove
        --, Browser.Events.onClick (Json.Decode.succeed OnMouseClick)
        ]



-- Main


main =
    Browser.document
        { view = view
        , subscriptions = subscriptions
        , update = update
        , init = init
        }
