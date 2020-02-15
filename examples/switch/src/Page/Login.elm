module Page.Login exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Update.Pipeline exposing (..)
import Update.Pipeline.Extended exposing (..)


type Msg
    = NoMsg


type alias Model =
    {}


init : a -> ( Model, Cmd Msg )
init _ =
    save Model


update :
    Msg
    -> { b | onSomething : Int -> a }
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
update msg { onSomething } model =
    save model
        |> andCall (onSomething 1)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html msg
view _ =
    div [] [ text "login" ]
