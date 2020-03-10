module Main exposing (..)

import Browser exposing (Document, document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Recipes.WebSocket as WebSocket
import Update.Pipeline exposing (..)


type Msg
    = NoMsg


type alias Model =
    {}


init : () -> ( Model, Cmd Msg )
init () =
    save Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            save model


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view {} =
    { title = "Websocket recipe example"
    , body =
        [         
        ]
    }


main : Program () Model Msg
main =
    document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
