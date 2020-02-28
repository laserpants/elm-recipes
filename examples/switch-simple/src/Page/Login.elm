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


init : {} -> ( Model, Cmd Msg )
init _ =
    save Model


update :
    Msg
    -> Model
    -> ( Model, Cmd Msg )
update msg model =
    save model


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html msg
view _ =
    div [] [ text "login" ]
