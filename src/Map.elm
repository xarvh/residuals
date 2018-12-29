module Map exposing (..)

import Dict exposing (Dict)
import TileCollision exposing (BlockerDirections)


type alias Tile =
    TileCollision.CollisionTile


tilemapSrc =
    """
 #
 #   ^^    ====
###       ##   # #
############### # #

"""


charToBlockers : Char -> BlockerDirections Bool
charToBlockers char =
    case char of
        '#' ->
            { positiveDeltaX = True
            , negativeDeltaX = True
            , positiveDeltaY = True
            , negativeDeltaY = True
            }

        '=' ->
            { positiveDeltaX = False
            , negativeDeltaX = False
            , positiveDeltaY = True
            , negativeDeltaY = True
            }

        '^' ->
            { positiveDeltaX = False
            , negativeDeltaX = False
            , positiveDeltaY = False
            , negativeDeltaY = True
            }

        _ ->
            { positiveDeltaX = False
            , negativeDeltaX = False
            , positiveDeltaY = False
            , negativeDeltaY = False
            }


type alias Tilemap =
    -- TODO this is slow, replace with an Array?
    Dict ( Int, Int ) Char


tilemap : Tilemap
tilemap =
    tilemapSrc
        |> String.split "\n"
        |> List.indexedMap rowToTuple
        |> List.concat
        |> Dict.fromList


rowToTuple : Int -> String -> List ( ( Int, Int ), Char )
rowToTuple invertedY row =
    let
        y =
            3 - invertedY

        charToTuple index char =
            ( ( index - 8, y )
            , char
            )
    in
    row
        |> String.toList
        |> List.indexedMap charToTuple


getBlockers : (BlockerDirections Bool -> Bool) -> Int -> Int -> Bool
getBlockers getter x y =
    case Dict.get ( x, y ) tilemap of
        Nothing ->
            False

        Just char ->
            char
                |> charToBlockers
                |> getter


hasBlockerAlong : BlockerDirections (Int -> Int -> Bool)
hasBlockerAlong =
    { positiveDeltaX = getBlockers .positiveDeltaX
    , negativeDeltaX = getBlockers .negativeDeltaX
    , positiveDeltaY = getBlockers .positiveDeltaY
    , negativeDeltaY = getBlockers .negativeDeltaY
    }
