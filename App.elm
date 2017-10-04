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


-- Hero


heroWidth =
    tileSize // 2


heroHeight =
    tileSize * 2 - 1



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


scanTiles : Int -> Int -> List Int
scanTiles start end =
    let
        initialTileIndex =
            start // tileSize

        recur tileIndex =
            if tileIndex * tileSize > end then
                []
            else
                tileIndex :: recur (tileIndex + 1)
    in
    recur initialTileIndex


hasVerticalObstacle : Int -> Int -> Int -> Bool
hasVerticalObstacle x bottom top =
    scanTiles bottom top
        |> List.any (\tileY -> getTileByIndices (x // tileSize) tileY /= Empty)


hasHorizontalObstacle : Int -> Int -> Int -> Bool
hasHorizontalObstacle left right y =
    scanTiles left right
        |> List.any (\tileX -> getTileByIndices tileX (y // tileSize) /= Empty)


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
            if dX < 0 && hasVerticalObstacle left bottom top then
                snapDownToTile (left + tileSize) + size.width // 2
            else if dX > 0 && hasVerticalObstacle right bottom top then
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
            if dY < 0 && hasHorizontalObstacle newLeft newRight newBottom then
                snapDownToTile (newBottom + tileSize) + size.height // 2
            else if dY > 0 && hasHorizontalObstacle newLeft newRight newTop then
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
    , Primitives.icosagon
        { color = 0.8
        , transform =
            Mat4.identity
                |> Mat4.translate3 (toFloat x) (toFloat y) 0
                |> Mat4.scale3 (toFloat heroWidth) (toFloat heroHeight) 1
                |> Mat4.translate3 0.5 0.35 0
                |> Mat4.scale3 0.7 0.3 1
                |> Mat4.mul viewMatrix
        }
    , Primitives.icosagon
        { color = 0.2
        , transform =
            Mat4.identity
                |> Mat4.translate3 (toFloat x) (toFloat y) 0
                |> Mat4.scale3 (toFloat heroWidth) (toFloat heroHeight) 1
                |> Mat4.translate3 0.6 0.35 0
                |> Mat4.scale3 0.4 0.2 1
                |> Mat4.mul viewMatrix
        }
    ]
      |> List.reverse


renderTile : List Vec -> Mat4 -> ( Int, Int ) -> Tile -> List WebGL.Entity
renderTile bright viewMatrix ( tileX, tileY ) tt =
    case tt of
        Empty ->
            []

        Slope leftHeight rightHeight ->
            let
                rotation =
                    if leftHeight > rightHeight then
                        0
                    else
                        turns 0.25

                size =
                    toFloat tileSize

                x =
                    toFloat tileX + 0.5

                y =
                    toFloat tileY + 0.5
            in
            [ Primitives.rightTriangle
                { color =
                    if List.member { x = tileX, y = tileY } bright then
                        0.8
                    else
                        0.3
                , transform =
                    Mat4.identity
                        |> Mat4.scale3 size size 1
                        |> Mat4.translate3 x y 0
                        |> Mat4.rotate rotation (vec3 0 0 1)
                        |> Mat4.mul viewMatrix
                }
            ]

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
