module Page.About exposing (..)

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
    -> b
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
update msg _ model =
    save model


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html msg
view _ =
    div [] [ text "about" ]
