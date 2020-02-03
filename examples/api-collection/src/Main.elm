module Main exposing (..)

import Browser exposing (Document, document)
import Data.Book as Book exposing (Book)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Recipes.Api.Collection as Api exposing (..)


type alias Flags =
    ()


type Msg
    = BookCollectionMsg (Api.Msg Book)


type alias Model =
    { api : Api.Collection Book
    }


init : Flags -> ( Model, Cmd Msg )
init () =
    Debug.todo ""


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    Debug.todo ""


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view { api } =
    Debug.todo ""


main : Program Flags Model Msg
main =
    document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
