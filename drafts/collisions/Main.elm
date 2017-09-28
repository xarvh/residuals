module Main exposing (..)

import Collision
import Dict exposing (Dict)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events
import Svg as S exposing (Svg)
import Svg.Attributes as SA


-- content


origin =
    { name = "+"
    , x = 0
    , y = 0
    }


draw : Float -> Point -> Point -> Point -> Point -> List (Svg msg)
draw radius aa bb cc dd =
    let
        ( a, b, c, d ) =
            ( p2v aa, p2v bb, p2v cc, p2v dd )

        fix =
            Collision.collision radius ( a, b ) ( c, d )
                |> Maybe.map (v2p >> drawCircle radius)
                |> Maybe.withDefault (text "")
    in
        [ drawSegment aa bb
        , drawSegment cc dd
        , drawPoint aa
        , drawPoint bb
        , drawPoint cc
        , drawPoint dd
        , drawCircle radius cc
        , drawCircle radius dd
        , fix
        ]



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
                Debug.crash <| "WTF" ++ (toString model.points)



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



-- init


init =
    [ { name = "A"
      , x = -0.1
      , y = -0.1
      }
    , { name = "B"
      , x = 0.6
      , y = 0.4
      }
    , { name = "C"
      , x = -0.2
      , y = 0.5
      }
    , { name = "D"
      , x = 0.5
      , y = 0.23
      }
    ]
        |> List.map (\p -> ( p.name, p ))
        |> Dict.fromList
        |> Model 0.01



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
                    Debug.crash <| "WTF: " ++ (toString msg)

        OnRadius valueAsString ->
            case String.toFloat valueAsString of
                Ok valueAsFloat ->
                    { model | radius = valueAsFloat }

                _ ->
                    Debug.crash <| "WTF: " ++ (toString msg)



-- view


radiusSlider : Float -> Html Msg
radiusSlider value =
    input
        [ Html.Events.onInput OnRadius
        , Html.Attributes.type_ "range"
        , Html.Attributes.max "0.1"
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
        , Html.Attributes.max "1"
        , Html.Attributes.min "-1"
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
            [ SA.viewBox "-1 -1 2 2"
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