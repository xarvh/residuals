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


-- Tiles


type Tile
    = Empty
    | Full
    | Slope Int Int


tileSize : Int
tileSize =
    1000


tiles : Array (Array Tile)
tiles =
    [ "===                  "
    , "=                   ="
    , "  ==  ==             "
    , "                     "
    , "                     "
    , "                     "
    , "      =========      "
    , "                     "
    , "                     "
    , "                     "
    , "  ===>          /=== "
    , "     =>        /     "
    , "       ========      "
    , "= =            ======"
    , "                     "
    , "                     "
    , "                     "
    , "                     "
    , "===                 ="
    , "== =============== =="
    ]
        |> List.reverse
        |> List.map (String.toList >> List.map charToTile >> Array.fromList)
        |> Array.fromList


charToTile : Char -> Tile
charToTile char =
    case char of
        '=' ->
            Full

        '>' ->
            Slope tileSize 0

        '/' ->
            Slope 0 tileSize

        _ ->
            Empty


getTileByIndices : Int -> Int -> Tile
getTileByIndices x y =
    tiles
        |> Array.get y
        |> Maybe.andThen (Array.get x)
        |> Maybe.withDefault Empty


getTileAt : Int -> Int -> Tile
getTileAt x y =
    getTileByIndices (x // tileSize) (y // tileSize)



-- Hero


heroWidth =
    tileSize


heroHeight =
    tileSize * 2



-- Types


type alias Vec =
    { x : Int
    , y : Int
    }


type alias Hero =
    { position : Vec
    , velocity : Vec
    }


type alias Model =
    { viewport : Viewport.Model
    , input : Input.Model
    , bright : List Vec
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
            , bright = []
            , hero =
                { position = Vec (tileSize * 5) (tileSize * 5)
                , velocity = Vec 0 0
                }
            }

        cmd =
            viewportCmd |> Cmd.map ViewportMsg
    in
    ( model, cmd )



-- update


type alias Size =
    { width : Int
    , height : Int
    }


tilesFromBottomToTop x bottom top =
    if bottom > top then
        False
    else if getTileAt x bottom /= Empty then
        True
    else
        tilesFromBottomToTop x (bottom + tileSize) top


tilesFromLeftToRight left right y =
    if left > right then
        False
    else if getTileAt left y /= Empty then
        True
    else
        tilesFromLeftToRight (left + tileSize) right y


snapDownToTile v =
    (v // tileSize) * tileSize


tileCollision : Size -> Vec -> ( Int, Int ) -> Vec
tileCollision size position ( dX, dY ) =
    let
        -- X
        idealX =
            position.x + dX

        left =
            idealX - size.width // 2

        right =
            idealX + size.width // 2

        top =
            position.y + size.height // 2

        bottom =
            position.y - size.height // 2

        newX =
            if dX < 0 && tilesFromBottomToTop left bottom top then
                snapDownToTile (left + tileSize) + size.width // 2
            else if dX > 0 && tilesFromBottomToTop right bottom top then
                snapDownToTile right - size.width // 2 - 1
            else
                idealX

        -- Y
        idealY =
            position.y + dY

        newTop =
            idealY + size.height // 2

        newBottom =
            idealY - size.height // 2

        newLeft =
            newX - size.width // 2

        newRight =
            newX + size.width // 2

        newY =
            if dY < 0 && tilesFromLeftToRight newLeft newRight newBottom then
                snapDownToTile (newBottom + tileSize) + size.height // 2
            else if dY > 0 && tilesFromLeftToRight newLeft newRight newTop then
                snapDownToTile newTop - size.height // 2 - 1
            else
                idealY
    in
    { x = newX
    , y = newY
    }


updateHero : Time -> Input.State -> Hero -> ( Hero, List Vec )
updateHero dt inputState hero =
    let
        speed =
            toFloat tileSize / 100

        ( dX, dY ) =
            inputState.move
                |> Math.clampToLength 1
                |> Vec2.scale (dt * speed)
                |> Vec2.toTuple
                |> Tuple.mapFirst round
                |> Tuple.mapSecond round

        fixedPosition =
            tileCollision
                { width = heroWidth
                , height = heroHeight
                }
                hero.position
                ( dX, dY )
    in
    ( { hero | position = fixedPosition }, [] )


updateFrame : Time -> Model -> Model
updateFrame dt model =
    let
        transformMouseCoordinates =
            Viewport.mouseToViewportCoordinates model.viewport

        inputState =
            Input.keyboardAndMouseInputState model.input transformMouseCoordinates

        ( newHero, bright ) =
            updateHero dt inputState model.hero
    in
    { model | hero = newHero, bright = bright }


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
    let
        size =
            toFloat tileSize

        x =
            hero.position.x

        y =
            hero.position.y
    in
    [ Primitives.quad
        { color = 0
        , transform =
            Mat4.identity
                |> Mat4.translate3 (toFloat x) (toFloat y) 0
                |> Mat4.scale3 (toFloat heroWidth) (toFloat heroHeight) 1
                |> Mat4.mul viewMatrix
        }
    ]


renderTile : List Vec -> Mat4 -> ( Int, Int ) -> Tile -> List WebGL.Entity
renderTile bright viewMatrix ( tileX, tileY ) tt =
    case tt of
        Empty ->
            []

        Slope left right ->
            []

        Full ->
            let
                size =
                    toFloat tileSize

                x =
                    toFloat tileX + 0.5

                y =
                    toFloat tileY + 0.5
            in
            [ Primitives.quad
                { color =
                    if List.member { x = tileX, y = tileY } bright then
                        0.8
                    else
                        0.3
                , transform =
                    Mat4.identity
                        |> Mat4.scale3 size size 1
                        |> Mat4.translate3 x y 0
                        |> Mat4.mul viewMatrix
                }
            ]


renderTiles : Model -> Mat4 -> List WebGL.Entity
renderTiles model viewMatrix =
    let
        mapRow yIndex row =
            row
                |> Array.toList
                |> List.indexedMap (\xIndex tile -> renderTile model.bright viewMatrix ( xIndex, yIndex ) tile)
    in
    tiles
        |> Array.toList
        |> List.indexedMap mapRow
        |> List.concat
        |> List.concat


view : Model -> Html Msg
view model =
    let
        gameAreaSize =
            20 * toFloat tileSize

        viewMatrix =
            Viewport.worldToCameraMatrix model.viewport gameAreaSize ( gameAreaSize / 2, gameAreaSize / 2 )
    in
    Html.div
        [ Html.Attributes.class "root" ]
        [ Html.node "style"
            []
            [ Html.text "html,head,body { padding:0; margin:0; border:0; }"
            , Html.text ".root { height:100vh; display:flex; align-items:center; justify-content:center; }"
            ]
        , [ renderTiles model viewMatrix
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
