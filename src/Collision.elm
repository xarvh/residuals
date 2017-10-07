module Collision exposing (..)

import Array exposing (Array)
import List.Extra
import Math
import Math.Vector2 as Vec2 exposing (Vec2, vec2)


-- types


type alias Polygon =
    List Vec2


type alias Collision =
    { direction : Vec2
    , distance : Float
    }



-- helpers


polygonToSegmentList : Polygon -> List ( Vec2, Vec2 )
polygonToSegmentList polygon =
    case polygon of
        [] ->
            []

        v :: vs ->
            List.map2 (,) polygon (List.append vs [ v ])



-- Static polygon distance


minimumDistancePolygonSegment : Polygon -> Vec2 -> Vec2 -> Float
minimumDistancePolygonSegment polygon segmentNormal anySegmentVertex =
    let
        distanceFromAxis vertex =
            Vec2.sub vertex anySegmentVertex
                |> Vec2.dot segmentNormal
    in
    polygon
        |> List.map distanceFromAxis
        |> List.minimum
        |> Maybe.withDefault 0


partialMinimumDistancePolygonPolygon : Polygon -> Polygon -> List Collision
partialMinimumDistancePolygonPolygon p q =
    let
        -- TODO cache normal?
        normalAndDistance ( a, b ) =
            let
                normal =
                    Vec2.sub a b |> Math.rotate90 |> Vec2.normalize
            in
            { direction = normal
            , distance = minimumDistancePolygonSegment q normal a
            }
    in
    p
        |> polygonToSegmentList
        |> List.map normalAndDistance


invertCollision : Collision -> Collision
invertCollision collision =
    { collision | direction = Vec2.negate collision.direction }


minimumDistancePolygonVsPolygon : Polygon -> Polygon -> Maybe Collision
minimumDistancePolygonVsPolygon p q =
    List.append
        (partialMinimumDistancePolygonPolygon p q |> List.map invertCollision)
        (partialMinimumDistancePolygonPolygon q p)
        |> List.Extra.minimumBy .distance



-- Static polygon collision


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
    p
        |> polygonToSegmentList
        |> List.any (normalIsSeparatingAxis q)
        |> not


collisionPolygonVsPolygon : Polygon -> Polygon -> Bool
collisionPolygonVsPolygon p q =
    halfCollision p q && halfCollision q p



--


collideRightEdge : Float -> Vec2 -> Vec2 -> Polygon -> Maybe Collision
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
    if collisionPolygonVsPolygon [ a, b, c, d ] obstacle then
        minimumDistancePolygonVsPolygon [ a, b, c, d ] obstacle
    else
        Nothing


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
rightCollision : Float -> Vec2 -> Vec2 -> List Polygon -> Maybe Collision
rightCollision height start end obstacles =
    if Vec2.getX (Vec2.sub end start) > 0 then
        obstacles
            |> List.filterMap (\o -> collideRightEdge height start end o)
            -- TODO: be smarter about multiple collisions
            |> List.Extra.minimumBy .distance
    else
        Nothing
