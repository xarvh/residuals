module Math exposing (..)

import Math.Vector2 as Vec2 exposing (Vec2, vec2)


rotate : Float -> Vec2 -> Vec2
rotate angle v =
    let
        ( x, y ) =
            Vec2.toTuple v

        sinA =
            sin angle

        cosA =
            cos angle
    in
        vec2
            (x * cosA - y * sinA)
            (x * sinA + y * cosA)


rotate90 : Vec2 -> Vec2
rotate90 v =
    let
        ( x, y ) =
            Vec2.toTuple v
    in
        vec2 -y x


clampToLength : Float -> Vec2 -> Vec2
clampToLength radius v =
    let
        ll =
            Vec2.lengthSquared v
    in
        if ll <= radius * radius then
            v
        else
            Vec2.scale (radius / sqrt ll) v
