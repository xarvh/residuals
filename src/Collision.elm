module Collision exposing (..)

import Array exposing (Array)
import List.Extra
import Math
import Math.Vector2 as Vec2 exposing (Vec2, vec2)


-- types


type alias Aabb =
    { center : Vec2
    , width : Float
    , height : Float
    }


type alias SegmentWithNormal =
    { pointA : Vec2
    , pointB : Vec2
    , normal : Vec2
    }


type alias Collision =
    { direction : Vec2
    , distance : Float
    }



-- helpers


polygonToSegments : List Vec2 -> List ( Vec2, Vec2 )
polygonToSegments polygon =
    case polygon of
        [] ->
            []

        v :: vs ->
            List.map2 (,) polygon (List.append vs [ v ])


polygonToSegmentWithNormals : List Vec2 -> List SegmentWithNormal
polygonToSegmentWithNormals polygon =
    let
        segmentWithNormal ( a, b ) =
            { pointA = a
            , pointB = b
            , normal = Vec2.sub a b |> Math.rotate90 |> Vec2.normalize
            }
    in
    polygon
        |> polygonToSegments
        |> List.map segmentWithNormal



-- Static polygon vs polygon collision CHECK


normalIsSeparatingAxis : List Vec2 -> ( Vec2, Vec2 ) -> Bool
normalIsSeparatingAxis polygonVertices ( a, b ) =
    let
        n =
            Math.rotate90 <| Vec2.sub b a

        isRightSide p =
            Vec2.dot n (Vec2.sub p a) > 0
    in
    List.all isRightSide polygonVertices


halfCollision : List Vec2 -> List Vec2 -> Bool
halfCollision p q =
    -- https://www.toptal.com/game/video-game-physics-part-ii-collision-detection-for-solid-objects
    -- Try polygon p's normals as separating axies.
    -- If any of them does separe the polys, then the two polys are NOT intersecting
    p
        |> polygonToSegments
        |> List.any (normalIsSeparatingAxis q)
        |> not


collisionPolygonVsPolygon : List Vec2 -> List Vec2 -> Bool
collisionPolygonVsPolygon p q =
    halfCollision p q && halfCollision q p



-- Static polygon vs polygon collision RESPONSE


projectOn : SegmentWithNormal -> Vec2 -> Float
projectOn segment vertex =
    Vec2.dot segment.normal (Vec2.sub vertex segment.pointA)


segmentToCollision : List Vec2 -> List Vec2 -> SegmentWithNormal -> Collision
segmentToCollision mobSweep obstacle segment =
    let
        min =
            mobSweep
                |> List.map (projectOn segment)
                |> List.minimum
                |> Maybe.withDefault 0

        max =
            obstacle
                |> List.map (projectOn segment)
                |> List.maximum
                |> Maybe.withDefault 0
    in
    { direction = segment.normal
    , distance = max - min
    }


polygonVsPolygonResponse : List Vec2 -> List Vec2 -> Maybe Collision
polygonVsPolygonResponse mobSweep obstacle =
    let
        invertNormal segment =
            { segment | normal = Vec2.negate segment.normal }

        mobSegments =
            mobSweep
                |> polygonToSegmentWithNormals
                |> List.map invertNormal

        obsSegments =
            obstacle
                |> polygonToSegmentWithNormals
    in
    mobSegments
        ++ obsSegments
        |> List.map (segmentToCollision mobSweep obstacle)
        |> List.Extra.minimumBy .distance



-- Moving Object vs polygon collision response


collideRightEdge : Aabb -> Vec2 -> List Vec2 -> Maybe Collision
collideRightEdge movingObjectAabb displacement obstacle =
    if Vec2.getX displacement <= 0 then
        Nothing
    else
        let
            halfWidth =
                vec2 (movingObjectAabb.width / 2) 0

            halfHeight =
                vec2 0 (movingObjectAabb.height / 2)

            -- `start` and `end` refer the edge center
            start =
                Vec2.add movingObjectAabb.center halfWidth

            end =
                Vec2.add start displacement

            {-
               Sweeping the edge AD along the displacement gives us the quadrilateral ABCD

                -A            B     -A--B
                 |\          /|      |  |
                 | \        / |      |  |
                 |  B     -A  |      |  |
                 |  |      |  |      |  |
                -D  |      |  C     -D--C
                  \ |      | /
                   \|      |/
                    C     -D
            -}
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
            polygonVsPolygonResponse [ a, b, c, d ] obstacle
        else
            Nothing


collideLeftEdge : Aabb -> Vec2 -> List Vec2 -> Maybe Collision
collideLeftEdge movingObjectAabb displacement obstacle =
    if Vec2.getX displacement >= 0 then
        Nothing
    else
        let
            halfWidth =
                vec2 (movingObjectAabb.width / 2) 0

            halfHeight =
                vec2 0 (movingObjectAabb.height / 2)

            -- `start` and `end` refer the edge center
            start =
                Vec2.sub movingObjectAabb.center halfWidth

            end =
                Vec2.add start displacement

            {-
               Sweeping the edge BC along the displacement gives us the quadrilateral ABCD

                 A            B-     A--B-
                 |\          /|      |  |
                 | \        / |      |  |
                 |  B-     A  |      |  |
                 |  |      |  |      |  |
                 D  |      |  C-     D--C-
                  \ |      | /
                   \|      |/
                    C-     D
            -}
            b =
                Vec2.add start halfHeight

            c =
                Vec2.sub start halfHeight

            a =
                Vec2.add end halfHeight

            d =
                Vec2.sub end halfHeight
        in
        if collisionPolygonVsPolygon [ b, c, d, a ] obstacle then
            polygonVsPolygonResponse [ b, c, d, a ] obstacle
        else
            Nothing


maybeFirst : List (() -> Maybe b) -> Maybe b
maybeFirst list =
    case list of
        [] ->
            Nothing

        x :: xs ->
            case x () of
                Just something ->
                    Just something

                Nothing ->
                    maybeFirst xs


mobVsObstacleCollisionResponse : Aabb -> Vec2 -> List Vec2 -> Maybe Collision
mobVsObstacleCollisionResponse movingObjectAabb displacement obstacle =
    [ \_ -> collideRightEdge movingObjectAabb displacement obstacle
    , \_ -> collideLeftEdge movingObjectAabb displacement obstacle
    ]
        |> maybeFirst
