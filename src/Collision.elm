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

```
           ^
           |
    c --s1---s2-----------------> d
           |
           |
           a----------------------------->
```

Equation for cd:

      y = cY

Equation for the circumference:

      x^2 + y^2 = r^2

The above have solutions:

      y = cY
      x = +- sqrt(r^2 - cY^2)

Which means that collisions happen if and only if

    r^2 - cY^2 > 0

Also, if solutions are present, we can take the one with the negative sign, as it is the one
closer to the trajectory start.


# Constraints

  - "Object should not jump" => CD should be longer than CS

  - "Object should stop at R distance from the point" => SA should be roughly equal to R

  - S should lay within C and D

-}
pointToPoint : Float -> Vec2 -> ( Vec2, Vec2 ) -> Maybe Collision
pointToPoint r a___ ( c___, d___ ) =
    if c___ == d___ then
        Nothing
    else
        let
            a_ =
                vec2 0 0

            c_ =
                Vec2.sub c___ a___

            d_ =
                Vec2.sub d___ a___

            -- coordinate transform: cd is horizontal
            x =
                Vec2.sub d_ c_ |> Vec2.normalize

            y =
                Math.rotate90 x

            changeBase v =
                vec2 (Vec2.dot v x) (Vec2.dot v y)

            -- new points
            a =
                changeBase a_

            c =
                changeBase c_

            d =
                changeBase d_

            -- cY
            cY =
                Vec2.getY c

            determinant =
                r * r - cY * cY
        in
        if determinant <= 0 then
            Nothing
        else if Vec2.distance d____ a____ < r then
          Just
            {

        else
            let
                -- find the solution coordinates
                sY =
                    cY

                sX =
                    -1 * sqrt (r * r - cY * cY)

                -- transform the solution coordinates
                s_ =
                    Vec2.add (Vec2.scale sX x) (Vec2.scale sY y)

                s___ =
                    Vec2.add s_ a___

                normal =
                    Vec2.sub s___ a___ |> Vec2.normalize

                (cX, cY) = Vec2.toTuple c
                (dX, dY) = Vec2.toTuple d
                l = dX - cX
            in
            --if (sX - cX) / l < -1e-2 then
            if sX - cX < 0 then
              Nothing
            else if sX > dX then
                Nothing
            else
                Just
                    { normal = normal
                    , parallel = Math.rotate90 normal
                    , position = s___
                    }


{-| Checks if a trajectory collides with an oriented segment.
If so, it returns a fixed final position for the trajectory.

Arguments:

*) r: collision radius

_) a, b: _oriented* obstacle segment.

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

  - D is above C (_no_ adjustment for radius)
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
            if iX < aX then
                -- intersection is outside and left of the segment
                pointToPoint r a ( c, d )
            else if iX > bX then
                -- intersection is outside and right of the segment
                pointToPoint r b ( c, d )
            else
                -- intersection is within the segment
                Just
                    { normal = y
                    , parallel = x
                    , position = Vec2.add (Vec2.scale iX x) (Vec2.scale iY y)
                    }
