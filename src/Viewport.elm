module Viewport exposing (..)

import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Mouse
import Task
import Window


viewportSize : Window.Size -> ( Float, Float )
viewportSize window =
    let
        viewportRatio =
            toFloat window.width / toFloat window.height

        viewportH =
            2

        viewportW =
            viewportH * viewportRatio
    in
    ( viewportW, viewportH )


mouseToViewportCoordinates : Window.Size -> Mouse.Position -> Vec2
mouseToViewportCoordinates window position =
    let
        -- window geometry
        ( wW, wH ) =
            ( toFloat window.width, toFloat window.height )

        -- mouse position in window coordinates
        ( mX, mY ) =
            ( toFloat position.x, toFloat position.y )

        -- viewport geometry
        ( vW, vH ) =
            viewportSize window

        x =
            vW * (mX / wW - 0.5)

        y =
            vH * ((wH / 2) - mY) / wH
    in
    vec2 x y


worldToCameraMatrix : Window.Size -> Float -> ( Float, Float ) -> Mat4
worldToCameraMatrix windowSize cameraSize ( cameraX, cameraY ) =
    let
        ( vW, vH ) =
            viewportSize windowSize

        projection =
            Mat4.makeScale3 (2 / vW) (2 / vH) 1

        camera =
            Mat4.makeScale3 (2 / cameraSize) (2 / cameraSize) 0
                |> Mat4.translate3 -cameraX -cameraY 0
    in
    Mat4.mul projection camera



-- TEA


type alias Model =
    Window.Size


type Msg
    = WindowResizes Window.Size


init : ( Model, Cmd Msg )
init =
    let
        model =
            { width = 100, height = 100 }

        cmd =
            Task.perform WindowResizes Window.size
    in
    ( model, cmd )


update : Msg -> Model -> Model
update msg model =
    case msg of
        WindowResizes size ->
            size


subscriptions : Model -> Sub Msg
subscriptions model =
    Window.resizes WindowResizes
