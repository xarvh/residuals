module Collision exposing (..)

import Math
import Math.Vector2 as Vec2 exposing (Vec2, vec2)


type alias Collision =
    { normal : Vec2
    , parallel : Vec2
    , position : Vec2
    }


{-| Checks if a trajectory collides with a point

*) r: collision radius

*) a: point

*) c: trajectory start

*) d: trajectory end

The circumference of radius `r` centered in `a` and the straight line
passing through `c` and `d` are described by two equations.

Collisions happen where the two equations intersect.

Intersection points can be found by solving the system of the two equations,
which yields a second grade polynomial.
The polynomial can have:

  - zero solutions: the objects are too far, no collision
  - one solution: the objects barely touch, no collision
  - two solutions: the objects overlap, collision must be resolved

The math becomes much easier if we resolve it in a coordinate system where:

  - cd is horizontal and going from left to right

  - a is at the origin

           ^
           |

    c --s1---s2-----------------> d
    |
    |
    |
    |
    a----------------------------->

Equation for cd:

      y = cY

Equation for the circumference:

      x^2 + y^2 = r^2

The above have solutions:

      y = cY
      x = +- sqrt(r^2 - cY^2)

Which means that collisions happen if and only if

    r^2 > cY^2

Also, if solutions are present, we can take the one with the negative sign, as it is the one
closer to the trajectory start.

-}
pointToPoint : Float -> Vec2 -> ( Vec2, Vec2 ) -> Maybe Collision
pointToPoint r a ( c, d ) =
    let
        -- coordinates ending in `_` use `a` as origin
        -- coordinates ending in `__` use `a` as origin and (d - c) as unit and positive direction
        c_ =
            Vec2.sub c a

        d_ =
            Vec2.sub d a

        -- coordinate transform: cd is horizontal
        -- since we do NOT normalise x and y, this transform changes the metric of our space
        x =
            Vec2.sub d c

        y =
            Math.rotate90 x

        xx =
            Vec2.lengthSquared x

        yy =
            xx

        -- r^2, with the new metric
        rr__ =
            r * r * xx

        c_dot_y =
            Vec2.dot c_ y

        -- cY__^2
        cYcY__ =
            c_dot_y * c_dot_y / yy
    in
        if rr__ <= cYcY__ then
            Nothing
        else
            let
                -- find normalised base
                nx =
                    Vec2.normalize x

                ny =
                    Math.rotate90 nx

                cY__ =
                    Vec2.dot c_ ny

                -- find the solution coordinates
                sY__ =
                    cY__

                sX__ =
                    -1 * sqrt (rr__ - cYcY__)

                -- transform the solution coordinates
                s =
                    Vec2.add (Vec2.scale sX__ nx) (Vec2.scale sY__ ny)

                normal =
                    Vec2.sub s a
            in
                Just
                    { normal = normal
                    , parallel = Math.rotate90 normal
                    , position = s
                    }


{-| Checks if a trajectory collides with an oriented segment.
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
pointToSegment : Float -> ( Vec2, Vec2 ) -> ( Vec2, Vec2 ) -> Maybe Collision
pointToSegment r ( a, b ) ( c, d ) =
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
            -- TODO: not all of these are needed before the checks
            ( aX, aY ) =
                xy a

            ( bX, bY ) =
                xy b

            ( cX, cY ) =
                xy c

            ( dX, dY ) =
                xy d
        in
            -- starting position is already past the segment
            if cY < aY then
                Nothing
                -- segment should only block movement opposite to its oriented normal
            else if dY >= cY then
                Nothing
                -- object will already stop before colliding
            else if dY - r >= aY then
                Nothing
            else
                let
                    -- intersection point between the trajectory of the bottom of the sphere
                    -- and the stright line that contains the segment
                    iY =
                        aY + r

                    iX =
                        (dX - cX) / (dY - cY) * (iY - cY) + cX
                in
                    -- intersection is outside and left of the segment
                    if iX < aX then
                        pointToPoint r a ( c, d )
                        -- intersection is outside and right of the segment
                    else if iX > bX then
                        pointToPoint r b ( c, d )
                        -- intersection is within the segment
                    else
                        let
                            fX =
                                dX

                            fY =
                                iY
                        in
                            Just
                                { normal = y
                                , parallel = x
                                , position = Vec2.add (Vec2.scale fX x) (Vec2.scale fY y)
                                }
