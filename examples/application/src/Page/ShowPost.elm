module Page.ShowPost exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Update.Pipeline exposing (save)
import Update.Pipeline.Extended exposing (Extended)


type Msg
    = NoMsg


type alias Model =
    {}


init : () -> ( Model, Cmd Msg )
init () =
    save Model


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


update :
    Msg
    -> { onAuthResponse : b, onAddPost : c }
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
update msg {} model =
    save model


view : Model -> Html Msg
view _ =
    div [] [ text "Show post" ]
