module CollisionTest exposing (..)

import Collision
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Test exposing (Test, describe)


type alias Point =
    ( Float, Float )


coordinateFuzzer : Fuzzer Float
coordinateFuzzer =
    Fuzz.frequency
        [ ( 1, Fuzz.floatRange -1000 1000 )
        , ( 1, Fuzz.floatRange -0.001 0.001 )
        ]


pointFuzzer : Fuzzer Point
pointFuzzer =
    Fuzz.map2 (,)
        coordinateFuzzer
        coordinateFuzzer


radiusFuzzer : Fuzzer Float
radiusFuzzer =
    Fuzz.frequency
        [ ( 1, Fuzz.floatRange 1 1000 )
        , ( 1, Fuzz.floatRange 0.1 1 )
        , ( 1, Fuzz.floatRange 0.001 0.1 )
        ]


pointToPointArgsFuzzer : Fuzzer ( Float, Point, Point, Point )
pointToPointArgsFuzzer =
    Fuzz.map4 (,,,)
        radiusFuzzer
        pointFuzzer
        pointFuzzer
        pointFuzzer


all : Test
all =
    describe "Collision.pointToPoint"
        [ Test.fuzz pointToPointArgsFuzzer "Moving object should not jump" <|
            \( radius, ( aX, aY ), ( cX, cY ), ( dX, dY ) ) ->
                let
                    a =
                        vec2 aX aY

                    c =
                        vec2 cX cY

                    d =
                        vec2 dX dY
                in
                case Collision.pointToPoint radius a ( c, d ) of
                    Nothing ->
                        Expect.pass

                    Just collision ->
                        Vec2.distanceSquared c d
                            |> Expect.greaterThan (Vec2.distanceSquared c collision.position)

        --
        , Test.fuzz pointToPointArgsFuzzer "Moving object should stop at radius distance from point" <|
            \( radius, ( aX, aY ), ( cX, cY ), ( dX, dY ) ) ->
                let
                    a =
                        vec2 aX aY

                    c =
                        vec2 cX cY

                    d =
                        vec2 dX dY
                in
                case Collision.pointToPoint radius a ( c, d ) of
                    Nothing ->
                        Expect.pass

                    Just collision ->
                        let
                            dd =
                                Vec2.distanceSquared a collision.position

                            rr =
                                radius * radius
                        in
                        -- dd should be roughly equal to rr
                        abs (dd / rr - 1)
                            |> Expect.lessThan 0.01

        --
        , Test.fuzz pointToPointArgsFuzzer "Collision point should lay on the trajectory" <|
            \( radius, ( aX, aY ), ( cX, cY ), ( dX, dY ) ) ->
                let
                    a =
                        vec2 aX aY

                    c =
                        vec2 cX cY

                    d =
                        vec2 dX dY
                in
                case Collision.pointToPoint radius a ( c, d ) of
                    Nothing ->
                        Expect.pass

                    Just collision ->
                        let
                            ( x, y ) =
                                Vec2.toTuple collision.position

                            -- https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line#Line_defined_by_two_points
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
                            |> Expect.lessThan 0.0001
        ]
