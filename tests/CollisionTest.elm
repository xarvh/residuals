module CollisionTest exposing (..)

import Collision
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Test exposing (Test, describe)


type alias Point =
    ( Float, Float )


pointFuzzer : Fuzzer Point
pointFuzzer =
    Fuzz.map2 (,)
        Fuzz.float
        Fuzz.float


pointToPointArgsFuzzer : Fuzzer ( Float, Point, Point, Point )
pointToPointArgsFuzzer =
    Fuzz.map4 (,,,)
        Fuzz.float
        pointFuzzer
        pointFuzzer
        pointFuzzer


all : Test
all =
    describe "Spread.spread"
        [ Test.fuzz pointToPointArgsFuzzer "moving object should not jump" <|
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
        ]
