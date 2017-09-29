module App exposing (..)

import AnimationFrame
import Html exposing (Html)
import Html.Attributes
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Matrix4 as Mat4 exposing (Mat4)
import WebGL
import Time exposing (Time)


--

import Collision
import Input
import Level0
import Math
import Obstacle exposing (Obstacle)
import Primitives
import Viewport


-- Globals


heroRadius =
    0.04



-- Types


type alias Hero =
    { position : Vec2
    , velocity : Vec2
    }


type alias Model =
    { obstacles : List Obstacle
    , viewport : Viewport.Model
    , input : Input.Model
    , hero : Hero
    }


type Msg
    = AnimationFrame Time
    | InputMsg Input.Msg
    | ViewportMsg Viewport.Msg



-- init


init : ( Model, Cmd Msg )
init =
    let
        ( viewport, viewportCmd ) =
            Viewport.init

        model =
            { obstacles = Level0.obstacles
            , viewport = viewport
            , input = Input.init
            , hero =
                { position = vec2 0 0
                , velocity = vec2 0 0
                }
            }

        cmd =
            viewportCmd |> Cmd.map ViewportMsg
    in
        ( model, cmd )



-- update


obsHeroCollision : Vec2 -> Vec2 -> Obstacle -> Maybe ( Vec2, Vec2 )
obsHeroCollision start end o =
    let
        ( a, b, c, d ) =
            case Obstacle.vertices o of
                [ a, b, c, d ] ->
                    ( a, b, c, d )

                _ ->
                    Debug.crash "vertices"
    in
        [ ( a, b ), ( b, c ), ( c, d ), ( d, a ) ]
        --[ ( a, b ) ]
            |> List.filterMap (\t -> Collision.pointToSegment heroRadius t ( start, end ))
            |> List.head


heroCollisions : Vec2 -> Vec2 -> List Obstacle -> Maybe ( Vec2, Vec2 )
heroCollisions c d obstacles =
    obstacles
        |> List.filterMap (obsHeroCollision c d)
        |> List.head


updateHero : Time -> Input.State -> List Obstacle -> Hero -> Hero
updateHero dt inputState obstacles hero =
    let
        thrust =
            0.000001

        gravity =
            thrust / 2

        drag =
            0.03

        thrustAcceleration =
            inputState.move
                |> Math.clampToLength 1.0
                |> Vec2.scale thrust

        gravityAcceleration =
            vec2 0 -gravity

        a =
            Vec2.add gravityAcceleration thrustAcceleration

        newVelocity =
            Vec2.add (Vec2.scale (1 - drag) hero.velocity) (Vec2.scale dt a)

        newPosition =
            Vec2.add hero.position (Vec2.scale dt newVelocity)

        maybeFix =
            heroCollisions hero.position newPosition obstacles

        ( fixedPosition, fixedVelocity ) =
            case maybeFix of
                Nothing ->
                    ( newPosition, newVelocity )

                Just ( surface, fixedPosition ) ->
                    ( fixedPosition
                      -- remove velocity component perpendicular to the surface
                    , Vec2.scale (Vec2.dot newVelocity surface) surface
                    )
    in
        { hero | position = fixedPosition, velocity = fixedVelocity }


updateFrame : Time -> Model -> Model
updateFrame dt model =
    let
        transformMouseCoordinates =
            Viewport.mouseToViewportCoordinates model.viewport

        inputState =
            Input.keyboardAndMouseInputState model.input transformMouseCoordinates
    in
        { model | hero = updateHero dt inputState model.obstacles model.hero }


update : Msg -> Model -> Model
update msg model =
    case msg of
        AnimationFrame dt ->
            updateFrame dt model

        InputMsg msg ->
            { model | input = Input.update msg model.input }

        ViewportMsg msg ->
            { model | viewport = Viewport.update msg model.viewport }



-- view


renderHero : Mat4 -> Hero -> WebGL.Entity
renderHero viewMatrix hero =
    let
        size =
            heroRadius * 2

        uniforms =
            { color = 0
            , transform =
                Mat4.identity
                    |> Mat4.translate3 (Vec2.getX hero.position) (Vec2.getY hero.position) 0
                    |> Mat4.rotate 0 (vec3 0 0 1)
                    |> Mat4.scale3 size size 1
                    |> Mat4.mul viewMatrix
            }
    in
        Primitives.icosagon uniforms



{-
   ro viewMatrix obstacle =
       let
           vertices =
               Obstacle.vertices obstacle
                 |> List.drop 1
                 |> List.take 2

           mesh =
               WebGL.points [ Primitives.MeshVertex (vec3 0 0 0) ]

           renderVertex v =
               let
                   uniforms =
                       { transform =
                           Mat4.identity
                               |> Mat4.translate3 (Vec2.getX v) (Vec2.getY v) 0
                               |> Mat4.mul viewMatrix
                       , color = 0
                       }
               in
                   WebGL.entity Primitives.vertexShader Primitives.fragmentShader mesh uniforms
       in
           List.map renderVertex vertices
-}


view : Model -> Html Msg
view model =
    let
        viewMatrix =
            Viewport.worldToCameraMatrix model.viewport

        hero =
            renderHero viewMatrix model.hero

        obstacles =
            List.map (Obstacle.render viewMatrix 0.3) model.obstacles
    in
        Html.div
            []
            [ Html.node "style"
                []
                [ Html.text "html,head,body { padding:0; margin:0; }"
                ]
            , [ obstacles
              , [ hero ]
              ]
                |> List.concat
                |> WebGL.toHtml
                    [ Html.Attributes.width model.viewport.width
                    , Html.Attributes.height model.viewport.height
                    ]
            ]



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Input.subscriptions model.input |> Sub.map InputMsg
        , Viewport.subscriptions model.viewport |> Sub.map ViewportMsg
        , AnimationFrame.diffs AnimationFrame
        ]



-- main


main =
    Html.program
        { init = init
        , update = \msg model -> ( update msg model, Cmd.none )
        , view = view
        , subscriptions = subscriptions
        }
