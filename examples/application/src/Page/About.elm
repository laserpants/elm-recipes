module Page.About exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ui.Page
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
    -> b
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
update msg _ model =
    save model


view : Model -> Html Msg
view _ =
    Ui.Page.container "About"
        [ text "Welcome to Facepalm — the place to meet weird people while keeping all your personal data safe."
        ]
