module Main exposing (..)

import Collision
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg as S exposing (Svg)
import Svg.Attributes as SA


-- init


q =
    ( c ( -0.03304070979356766, -0.39863303303718567 )
    , d ( -0.030142653733491898, -0.39863303303718567 )
    , s ( -0.03304095899900713, -0.39863303303718567 )
    )


init =
    { radius = 0.4
    , points =
        [ { name = "A"
          , x = -0.6678766012191772 - 0.5 / 2
          , y = -0.44464609026908875 + 0.1 / 2
          }
        , { name = "B"
          , x = -0.6678766012191772 + 0.5 / 2
          , y = -0.44464609026908875 + 0.1 / 2
          }
        , { name = "C"
          , x = -1.095051646232605
          , y = -0.03602510690689087
          }
        , { name = "D"
          , x = -1.0989317893981934
          , y = -0.038303084671497345
          }
        ]
            |> List.map (\p -> ( p.name, p ))
            |> Dict.fromList
    }


draw : Float -> Point -> Point -> Point -> Point -> List (Svg msg)
draw radius aa bb cc dd =
    let
        ( a, b, c, d ) =
            ( p2v aa, p2v bb, p2v cc, p2v dd )

        maybeCollision =
            --Collision.pointToSegment radius ( a, b ) ( c, d )
            Collision.pointToPoint radius a ( c, d )

        fix =
            case maybeCollision of
                Nothing ->
                    []

                Just collision ->
                    let
                        p =
                            collision.position |> v2p

                        n1 =
                            Vec2.add collision.position (Vec2.scale 0.1 collision.normal) |> v2p

                        n2 =
                            Vec2.add collision.position (Vec2.scale 0.1 collision.parallel) |> v2p
                    in
                    [ drawSegment p n1
                    , drawSegment p n2
                    , drawCircle radius p
                    ]
    in
    [ drawSegment aa bb
    , drawSegment cc dd
    , drawPoint aa
    , drawPoint bb
    , drawPoint cc
    , drawPoint dd
    , drawCircle radius cc
    , drawCircle radius dd
    ]
        ++ fix



-- entities


v2p : Vec2 -> Point
v2p v =
    { name = ""
    , x = Vec2.getX v
    , y = Vec2.getY v
    }


p2v : Point -> Vec2
p2v p =
    vec2 p.x p.y


drawSegment : Point -> Point -> Svg msg
drawSegment start end =
    S.line
        [ SA.x1 <| toString <| start.x
        , SA.y1 <| toString <| start.y
        , SA.x2 <| toString <| end.x
        , SA.y2 <| toString <| end.y
        , SA.strokeWidth "0.003"
        , SA.stroke "grey"

        -- TODO
        , SA.markerEnd """<path d="M2,2 L2,11 L10,6 L2,2" style="fill: #000000;" />"""
        ]
        []


drawCircle : Float -> Point -> Svg msg
drawCircle radius p =
    S.circle
        [ SA.cx <| toString <| p.x
        , SA.cy <| toString <| p.y
        , SA.r <| toString <| radius
        , SA.fill "none"
        , SA.stroke "grey"
        , SA.strokeWidth "0.01"
        ]
        []


drawPoint : Point -> Svg msg
drawPoint p =
    let
        size =
            0.01
    in
    S.g
        []
        [ S.circle
            [ SA.cx <| toString <| p.x
            , SA.cy <| toString <| p.y
            , SA.r <| toString <| size
            ]
            []
        , S.text_
            [ SA.fontSize "0.05"
            , SA.transform <| "translate(" ++ toString (p.x + size) ++ "," ++ toString p.y ++ ") scale(1, -1)"
            ]
            [ text <| " " ++ p.name ]
        ]


entitiesView : Model -> List (Svg msg)
entitiesView model =
    let
        get s =
            Dict.get s model.points
    in
    case Maybe.map4 (draw model.radius) (get "A") (get "B") (get "C") (get "D") of
        Just entities ->
            entities

        Nothing ->
            Debug.crash <| "WTF" ++ toString model.points



-- content


type alias PointId =
    String


type alias Point =
    { name : PointId
    , x : Float
    , y : Float
    }



-- types


type alias Model =
    { radius : Float
    , points : Dict String Point
    }


type Msg
    = OnSlider String String String
    | OnRadius String



-- update


updatePoint : String -> Float -> Point -> Point
updatePoint coordinate value point =
    if coordinate == "x" then
        { point | x = value }
    else
        { point | y = value }


update : Msg -> Model -> Model
update msg model =
    case msg of
        OnSlider pointName coordinate valueAsString ->
            case ( String.toFloat valueAsString, Dict.get pointName model.points ) of
                ( Ok valueAsFloat, Just point ) ->
                    { model | points = Dict.insert pointName (updatePoint coordinate valueAsFloat point) model.points }

                _ ->
                    Debug.crash <| "WTF: " ++ toString msg

        OnRadius valueAsString ->
            case String.toFloat valueAsString of
                Ok valueAsFloat ->
                    { model | radius = valueAsFloat }

                _ ->
                    Debug.crash <| "WTF: " ++ toString msg



-- view


radiusSlider : Float -> Html Msg
radiusSlider value =
    input
        [ Html.Events.onInput OnRadius
        , Html.Attributes.type_ "range"
        , Html.Attributes.max "0.5"
        , Html.Attributes.min "0.01"
        , Html.Attributes.step "any"
        , Html.Attributes.defaultValue <| toString value
        ]
        []


slider : String -> String -> Float -> Html Msg
slider pointName coordinate value =
    input
        [ Html.Events.onInput (OnSlider pointName coordinate)
        , Html.Attributes.type_ "range"
        , Html.Attributes.max "2"
        , Html.Attributes.min "-2"
        , Html.Attributes.step "any"
        , Html.Attributes.defaultValue <| toString value
        ]
        []


pointToSliders : Point -> Html Msg
pointToSliders p =
    div
        [ style
            [ ( "display", "flex" )
            ]
        ]
        [ text p.name
        , slider p.name "x" p.x
        , slider p.name "y" p.y
        ]


slidersView : Model -> Html Msg
slidersView model =
    model.points
        |> Dict.values
        |> List.sortBy .name
        |> List.map pointToSliders
        |> (::) (radiusSlider model.radius)
        |> div []


view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "display", "flex" )
            ]
        ]
        [ slidersView model
        , S.svg
            [ SA.viewBox "-1.7 -1 2 2"
            , style
                [ ( "width", "50%" )
                , ( "height", "50%" )
                ]
            ]
            [ S.g
                [ SA.transform "scale(1, -1)" ]
                (entitiesView model)
            ]
        ]



-- main


noCmd model =
    ( model, Cmd.none )


main =
    Html.program
        { init = noCmd init
        , update = \msg model -> update msg model |> noCmd
        , view = view
        , subscriptions = always Sub.none
        }
