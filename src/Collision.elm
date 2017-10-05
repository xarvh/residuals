module Collision exposing (..)

import Array exposing (Array)
import Math
import Math.Vector2 as Vec2 exposing (Vec2, vec2)


-- types


type alias Polygon =
    List Vec2



-- helpers


anyPoligonSegment : (( Vec2, Vec2 ) -> Bool) -> Polygon -> Bool
anyPoligonSegment f poly =
    let
        a =
            Array.fromList poly

        get index =
            Array.get (index % Array.length a) a |> Maybe.withDefault (vec2 0 0)

        segments =
            List.indexedMap (\index v -> ( get index, get (index + 1) )) poly
    in
    List.any f segments



-- static polygon collision


normalIsSeparatingAxis : Polygon -> ( Vec2, Vec2 ) -> Bool
normalIsSeparatingAxis polygon ( a, b ) =
    let
        n =
            Math.rotate90 <| Vec2.sub b a

        isRightSide p =
            Vec2.dot n (Vec2.sub p a) > 0
    in
    List.all isRightSide polygon


halfCollision : Polygon -> Polygon -> Bool
halfCollision p q =
    -- https://www.toptal.com/game/video-game-physics-part-ii-collision-detection-for-solid-objects
    -- Try polygon p's normals as separating axies.
    -- If any of them does separe the polys, then the two polys are NOT intersecting
    not <| anyPoligonSegment (normalIsSeparatingAxis q) p


collisionPolygonVsPolygon : Polygon -> Polygon -> Bool
collisionPolygonVsPolygon p q =
    halfCollision p q && halfCollision q p



--


collideRightEdge : Float -> Vec2 -> Vec2 -> Polygon -> Bool
collideRightEdge height start end obstacle =
    let
        {-
           This function should be called only if the displacement has a positive X coordinate

           Sweeping the edge AD along the displacement gives us the quadrilateral ABCD

             A            B      A--B
             |\          /|      |  |
             | \        / |      |  |
             |  B      A  |      |  |
             |  |      |  |      |  |
             D  |      |  C      D--C
              \ |      | /
               \|      |/
                C      D
        -}
        halfHeight =
            vec2 0 (height / 2)

        a =
            Vec2.add start halfHeight

        d =
            Vec2.sub start halfHeight

        b =
            Vec2.add end halfHeight

        c =
            Vec2.sub end halfHeight
    in
    collisionPolygonVsPolygon [ a, b, c, d ] obstacle


{-| Binary search along the trajectory for the furthest point that does NOT collide

  - Assuming that end point is colliding

-}
searchFurthestNonCollidingEnd : Int -> (Vec2 -> Vec2 -> Bool) -> ( Vec2, Vec2 ) -> Vec2
searchFurthestNonCollidingEnd remainingIterations isColliding ( start, end ) =
    if remainingIterations < 1 then
        -- `start` is the only point that's always acceptable, because it means "no displacement"
        start
    else
        let
            midPoint =
                Vec2.add start end |> Vec2.scale 0.5

            ( newStart, newEnd ) =
                if isColliding start midPoint then
                    ( start, midPoint )
                else
                    ( midPoint, end )
        in
        searchFurthestNonCollidingEnd (remainingIterations - 1) isColliding ( newStart, newEnd )


{-|

  - Assuming that every passed obstacle collides with the object's motion

-}
rightCollision : Float -> Vec2 -> Vec2 -> List Polygon -> Maybe Vec2
rightCollision height start end obstacles =
    let
        isColliding s e =
            List.any (\o -> collideRightEdge height s e o) obstacles
    in
    if Vec2.getX (Vec2.sub end start) > 0 && isColliding start end then
        searchFurthestNonCollidingEnd 10 isColliding ( start, end ) |> Just
    else
        Nothing
