module Collision exposing (..)

import Math
import Math.Vector2 as Vec2 exposing (Vec2, vec2)


vecToBase : Vec2 -> ( Vec2, Vec2 )
vecToBase v =
    let
        e1 =
            Vec2.normalize v

        e2 =
            Math.rotate90 e1
    in
        ( e1, e2 )


segmentToBase : Vec2 -> Vec2 -> ( Vec2, Vec2 )
segmentToBase a b =
    Vec2.sub b a |> vecToBase


{-| Checks if a trajectory collides with an oriented surface.
If so, it returns a fixed final position for the trajectory.

Arguments:

*) r: collision radius

*) a, b: *oriented* obstacle segment.

    - Collision will happen only if the collider comes from the left side of the segment direction
    - a and b are assumed to be different

*) c: current collider position

*) d: updated position

We use a reference frame where AB is horizontal:

    i : intersection point
    f : fixed destination

    ^
    |         c
    |          \   f
    |       a---i--|-------->b
    |            \ |
    |             \|
    |              d
    |
    +---------------------------------->

We can exclude collision if any of these conditions is true:

  - D is above C (*no* adjustment for radius)
  - D is above AB (adjust for radius)
  - I is left of A (adjust for radius)
  - I is right of B (adjust for radius)

-}
collision : Float -> ( Vec2, Vec2 ) -> ( Vec2, Vec2 ) -> Maybe ( Vec2, Vec2 )
collision r ( a, b ) ( c, d ) =
    if a == b || c == d then
        Nothing
    else
        let
            -- Base element parallel to AB
            -- TODO: this is the only expensive computation, it might be useful to precalculate it
            x =
                Vec2.sub b a |> Vec2.normalize

            -- Base element perpendicular to AB (directed  towards its left)
            y =
                Math.rotate90 x

            xy p =
                ( Vec2.dot x p, Vec2.dot y p )

            -- point components along the base
            -- TODO: not all of these are needed
            ( aX, aY ) =
                xy a

            ( bX, bY ) =
                xy b

            ( cX, cY ) =
                xy c

            ( dX, dY ) =
                xy d
        in
            -- starting position is already past the surface
            if cY < aY then
                Nothing
                -- surface should only block movement opposite to its normal
            else if dY >= cY then
                Nothing
                -- object will already stop before colliding
            else if dY - r >= aY then
                Nothing
            else
                let
                    -- intersection point
                    iY =
                        aY

                    iX =
                        (dX - cX) / (dY - cY) * (aY - cY) + cX

                    fX =
                        dX

                    fY =
                        aY + r
                in
                    if iX + r < aX then
                        Nothing
                    else if iX - r > bX then
                        Nothing
                    else
                        Vec2.add (Vec2.scale fX x) (Vec2.scale fY y)
                            |> (,) x
                            |> Just
