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


pointToLineSquaredDistance : Vec2 -> ( Vec2, Vec2 ) -> Float
pointToLineSquaredDistance p ( c, d ) =
    let
        ( x, y ) =
            Vec2.toTuple p

        ( cX, cY ) =
            Vec2.toTuple c

        ( dX, dY ) =
            Vec2.toTuple d

        -- shamelessly copied from https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line#Line_defined_by_two_points
        deltaX =
            dX - cX

        deltaY =
            dY - cY

        n =
            deltaY * x - deltaX * y + dX * cY - dY * cX

        dd =
            deltaY * deltaY + deltaX * deltaX

        squaredDistance =
            n * n / dd
    in
    squaredDistance
