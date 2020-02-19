module Page.Home exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Update.Pipeline exposing (save)


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


update msg {} model =
    save model


view : Model -> Html Msg
view _ =
    div [] [ text "Home" ]
