module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time exposing (Time, second)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Button as Button


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
    }



-- MESSAGES


type Msg
    = Tick Time
    | StartGame
    | EndGame



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
                        [ "game-over-bell" ]
                    else if model.mode == Playing then
                        getCountdownAudio turnTime
                    else
                        []

                commands =
                    List.map (\e -> Cmd.none) audioEvents

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
                { newModel | mode = Playing } ! []

        EndGame ->
                { model | mode = Stopped } ! []


getCountdownAudio : Int -> List String
getCountdownAudio n =
    if n % 10 > 0 then
        []
    else
        case n of
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
    Grid.container []
        [ Grid.row []
            [ Grid.col []
                [ Card.config [ Card.outlinePrimary ]
                    |> Card.headerH4 [] [ text "Snooker Shootout Timer" ]
                    |> Card.block []
                        [ Block.custom <| showCounter model
                        ]
                    |> Card.block []
                        [ Block.custom <|
                            Grid.row []
                                [ Grid.col []
                                    [ Button.button [ Button.success, Button.block, Button.disabled (model.mode /= Busy) ]
                                        [ text "Start shot" ]
                                    ]
                                , Grid.col []
                                    [ Button.button [ Button.danger, Button.block, Button.disabled (model.mode /= Playing) ]
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
        div []
            [ text "GAME TIME: "
            , span [ style [ ( "color", c ) ] ]
                [ text <| formatGameTime n ]
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
        div []
            [ text "SHOT TIME: "
            , span [ style [ ( "color", c ) ] ]
                [ text <| formatShotTime n ]
            ]


formatGameTime : Int -> String
formatGameTime n =
    (n // 600 |> toString) ++ ":" ++ String.padLeft 2 '0' (n % 600 // 10 |> toString)


formatShotTime : Int -> String
formatShotTime n =
    (n // 10 |> toString) ++ "." ++ (n % 10 |> toString)
