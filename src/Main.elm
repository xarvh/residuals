module Main exposing (..)

import Browser
import Browser.Events
import Game
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Json.Decode exposing (Decoder)
import Map
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Scene
import TileCollision exposing (Vector)
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
    }


type Msg
    = OnResize PixelSize
    | OnAnimationFrame Float



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

        OnAnimationFrame dtInMilliseconds ->
            let
                -- dt is in seconds
                dt =
                    dtInMilliseconds / 1000

                player =
                    Game.playerThink dt model.player
            in
            noCmd
                { model
                    | currentTimeInSeconds = model.currentTimeInSeconds + dt
                    , player = player
                }



-- View


view : Model -> Browser.Document Msg
view model =
    let
        entities =
            Scene.entities
                { cameraToViewport = Viewport.worldToPixelTransform model.viewportSize 10 --Map.worldSize
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
        , Browser.Events.onAnimationFrameDelta OnAnimationFrame

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
