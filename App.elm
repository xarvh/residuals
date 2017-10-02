module App exposing (..)

--

import AnimationFrame
import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes
import Input
import List.Extra
import Math
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Primitives
import Time exposing (Time)
import Viewport
import WebGL


-- Globals


tiles : Array (Array Bool)
tiles =
    [ "***                  "
    , "*                   *"
    , "  **  **             "
    , "                     "
    , "                     "
    , "*********************"
    , "                     "
    , "                     "
    , "                     "
    , "                     "
    , "                     "
    , "                     "
    , "                     "
    , "                     "
    , "                     "
    , "                     "
    , "                     "
    , "                     "
    , "***                 *"
    , "** *************** **"
    ]
        |> List.reverse
        |> List.map (String.toList >> List.map ((==) '*') >> Array.fromList)
        |> Array.fromList


tile : ( Int, Int ) -> Bool
tile ( x, y ) =
    tiles
        |> Array.get y
        |> Maybe.andThen (Array.get y)
        |> Maybe.withDefault True


tileSize : Int
tileSize =
    1000


type alias Vec =
    { x : Int
    , y : Int
    }



-- Types


type alias Hero =
    { position : Vec
    , velocity : Vec
    }


type alias Model =
    { viewport : Viewport.Model
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
            { viewport = viewport
            , input = Input.init
            , hero =
                { position = Vec 0 0
                , velocity = Vec 0 0
                }
            }

        cmd =
            viewportCmd |> Cmd.map ViewportMsg
    in
    ( model, cmd )



-- update


updateHero : Time -> Input.State -> Hero -> Hero
updateHero dt inputState hero =
    hero


updateFrame : Time -> Model -> Model
updateFrame dt model =
    let
        transformMouseCoordinates =
            Viewport.mouseToViewportCoordinates model.viewport

        inputState =
            Input.keyboardAndMouseInputState model.input transformMouseCoordinates
    in
    { model | hero = updateHero dt inputState model.hero }


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


renderHero : Mat4 -> Hero -> List WebGL.Entity
renderHero viewMatrix hero =
    []


renderTile : Mat4 -> ( Int, Int ) -> Bool -> List WebGL.Entity
renderTile viewMatrix ( tileX, tileY ) tile =
    if tile then
        let
            x =
                toFloat tileX + 0.5

            y =
                toFloat tileY + 0.5
        in
        [ Primitives.quad
            { color = 0.3
            , transform =
                Mat4.identity
                    |> Mat4.scale3 1 1 1
                    |> Mat4.translate3 x y 0
                    |> Mat4.mul viewMatrix
            }
        ]
    else
        []


renderTiles : Mat4 -> List WebGL.Entity
renderTiles viewMatrix =
    let
        mapRow yIndex row =
            row
                |> Array.toList
                |> List.indexedMap (\xIndex tile -> renderTile viewMatrix ( xIndex, yIndex ) tile)
    in
    tiles
        |> Array.toList
        |> List.indexedMap mapRow
        |> List.concat
        |> List.concat


view : Model -> Html Msg
view model =
    let
        viewMatrix =
            Viewport.worldToCameraMatrix model.viewport 20 ( 10, 10 )
    in
    Html.div
        [ Html.Attributes.class "root" ]
        [ Html.node "style"
            []
            [ Html.text "html,head,body { padding:0; margin:0; border:0; }"
            , Html.text ".root { height:100vh; display:flex; align-items:center; justify-content:center; }"
            ]
        , [ renderTiles viewMatrix
          , renderHero viewMatrix model.hero
          ]
            |> List.concat
            |> WebGL.toHtml
                [ Html.Attributes.width model.viewport.width
                , Html.Attributes.height model.viewport.height
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
