port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time exposing (Time, second)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Button as Button
import Task
import Dict


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { gameTime : Int
    , turnTime : Int
    , mode : GameMode
    , warnedAboutFastMode : Bool
    }


type GameMode
    = Stopped
    | Playing
    | Busy


init : ( Model, Cmd Msg )
init =
    initModel ! []


initModel : Model
initModel =
    { gameTime = 6000
    , turnTime = 150
    , mode = Stopped
    , warnedAboutFastMode = False
    }


audioClips =
    [ "buzzer.ogg"
    , "shotclock-10s.ogg"
    , "shotclock-15s.ogg"
    , "game-over.ogg"
    , "5.ogg"
    , "4.ogg"
    , "3.ogg"
    , "2.ogg"
    , "1.ogg"
    ]



-- MESSAGES


type Msg
    = Tick Time
    | StartGame
    | EndGame
    | StartShot
    | EndShot



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick time ->
            let
                turnTime =
                    model.turnTime - 1

                gameTime =
                    model.gameTime - 1

                audioEvents =
                    if gameTime <= 0 && model.mode /= Stopped then
                        [ "game-over" ]
                    else if model.mode == Playing then
                        getCountdownAudio turnTime
                    else
                        []

                commands =
                    List.map (\e -> playAudio (e ++ ".ogg")) audioEvents

                mode =
                    if gameTime <= 0 then
                        Stopped
                    else if turnTime > 0 then
                        model.mode
                    else
                        Busy

                newModel =
                    case model.mode of
                        Stopped ->
                            model

                        Busy ->
                            { model | gameTime = gameTime, mode = mode }

                        Playing ->
                            { model | gameTime = gameTime, turnTime = turnTime, mode = mode }
            in
                newModel ! commands

        StartGame ->
            let
                newModel =
                    initModel
            in
                { newModel | mode = Playing } ! [ playAudio "shotclock-15s.ogg" ]

        EndGame ->
            { model | mode = Stopped } ! []

        StartShot ->
            let
                turnTime =
                    if model.gameTime < 5 * 60 * 10 then
                        100
                    else
                        150

                ( warnedAboutFastMode, audioCommands ) =
                    if not model.warnedAboutFastMode && turnTime == 100 then
                        ( True, [ playAudio "shotclock-10s.ogg" ] )
                    else
                        ( model.warnedAboutFastMode, [] )
            in
                { model | turnTime = turnTime, mode = Playing, warnedAboutFastMode = warnedAboutFastMode } ! audioCommands

        EndShot ->
            { model | mode = Busy } ! []


getCountdownAudio : Int -> List String
getCountdownAudio n =
    if n % 10 > 0 then
        []
    else
        case n // 10 of
            5 ->
                [ "5" ]

            4 ->
                [ "4" ]

            3 ->
                [ "3" ]

            2 ->
                [ "2" ]

            1 ->
                [ "1" ]

            0 ->
                [ "buzzer" ]

            _ ->
                []



-- PORTS


port playAudio : String -> Cmd msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.mode /= Stopped then
        Time.every (0.1 * second) Tick
    else
        Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ style [ ( "padding-top", "2%" ) ] ]
        [ Grid.container []
            [ Grid.row []
                [ Grid.col []
                    [ Card.config [ Card.outlinePrimary ]
                        |> Card.block []
                            [ Block.custom <| showCounter model
                            ]
                        |> Card.block []
                            [ Block.custom <|
                                Grid.row []
                                    [ Grid.col []
                                        [ Button.button [ Button.success, Button.block, Button.disabled (model.mode /= Busy), Button.onClick StartShot ]
                                            [ text "Start shot" ]
                                        ]
                                    , Grid.col []
                                        [ Button.button [ Button.danger, Button.block, Button.disabled (model.mode /= Playing), Button.onClick EndShot ]
                                            [ text "Finish shot" ]
                                        ]
                                    ]
                            ]
                        |> Card.block []
                            [ Block.custom <|
                                showGameStartButton model.mode
                            ]
                        |> Card.view
                    ]
                ]
            ]
        , makeAudioObjects
        ]


makeAudioObjects =
    div [] <|
        List.map (\url -> audio [ id url ] [ source [ src url ] [] ]) audioClips


showGameStartButton : GameMode -> Html Msg
showGameStartButton mode =
    case mode of
        Stopped ->
            Button.button
                [ Button.outlinePrimary, Button.small, Button.block, Button.onClick StartGame ]
                [ text "Start game" ]

        _ ->
            Button.button
                [ Button.outlineDanger, Button.small, Button.block, Button.onClick EndGame ]
                [ text "End game" ]


showCounter : Model -> Html Msg
showCounter model =
    div []
        [ showGameTimer model, showShotTimer model ]


showGameTimer : Model -> Html Msg
showGameTimer model =
    let
        n =
            model.gameTime

        c =
            if n < 3000 then
                "orange"
            else
                "green"
    in
        div [ style [ ( "text-align", "center" ) ] ]
            [ h4 [] [ text "GAME TIME" ]
            , h4 []
                [ span [ style [ ( "color", c ) ] ]
                    [ text <| formatGameTime n ]
                ]
            ]


showShotTimer : Model -> Html Msg
showShotTimer model =
    let
        n =
            model.turnTime

        c =
            if n < 50 then
                "red"
            else
                "green"
    in
        div [ style [ ( "text-align", "center" ) ] ]
            [ h4 [] [ text "SHOT TIME" ]
            , h4 []
                [ span [ style [ ( "color", c ) ] ]
                    [ text <| formatShotTime n ]
                ]
            ]


formatGameTime : Int -> String
formatGameTime n =
    (n // 600 |> toString) ++ ":" ++ String.padLeft 2 '0' (n % 600 // 10 |> toString)


formatShotTime : Int -> String
formatShotTime n =
    (n // 10 |> toString) ++ "." ++ (n % 10 |> toString)


logoStyle : List ( String, String )
logoStyle =
    [ ( "width", "95%" ), ( "max-height", "200px" ), ( "object-fit", "contain" ) ]
