module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time exposing (Time, second)


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
    , playing : Bool
    }


init : ( Model, Cmd Msg )
init =
    { gameTime = 6000
    , turnTime = 150
    , playing = True
    }
        ! []



-- MESSAGES


type Msg
    = Tick Time



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

                playing =
                    model.playing && turnTime > 0

                newModel =
                    if model.playing then
                        { model | gameTime = gameTime, turnTime = turnTime, playing = playing }
                    else
                        model
            in
                newModel ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.playing then
        Time.every (0.1 * second) Tick
    else
        Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    showCounter model


showCounter : Model -> Html Msg
showCounter model =
    div
        []
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
        div
            [ style [ ( "color", c ) ] ]
            [ text <| formatGameTime n ]


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
        div
            [ style [ ( "color", c ) ] ]
            [ text <| formatShotTime n ]


formatGameTime : Int -> String
formatGameTime n =
    (n // 600 |> toString) ++ ":" ++ String.padLeft 2 '0' (n % 600 // 10 |> toString)

formatShotTime : Int -> String
formatShotTime n =
    (n // 10 |> toString) ++ "." ++ (n % 10 |> toString)
