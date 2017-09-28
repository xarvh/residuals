module Viewport exposing (..)

import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Mouse
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


worldToCameraMatrix : Window.Size -> Mat4
worldToCameraMatrix window =
    let
        ( vW, vH ) =
            viewportSize window

        projection =
            Mat4.makeScale3 (2 / vW) (2 / vH) 1

        camera =
            Mat4.identity
    in
        Mat4.mul projection camera
