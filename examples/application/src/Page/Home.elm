module Page.Home exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Update.Pipeline exposing (save)
import Update.Pipeline.Extended exposing (Extended)


type Msg
    = NoMsg


type alias Model =
    {}


init : {} -> ( Model, Cmd Msg )
init _ =
    save Model


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


update :
    Msg
    -> { onAuthResponse : b }
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
update msg {} model =
    Debug.todo ""


view : Model -> Html Msg
view _ =
    div [] [ text "Home" ]
