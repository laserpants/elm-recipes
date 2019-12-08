module Main exposing (..)

import Browser exposing (Document, document)
import Form.Register as RegistrationForm
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Update.Form as Form
import Update.Pipeline exposing (..)
import Update.Router as Router exposing (Router, forceUrlChange, handleUrlChange, handleUrlRequest)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, parse)


type alias Flags =
    ()


type Msg
    = FormMsg RegistrationForm.Msg


type alias Model =
    { form : RegistrationForm.Model
    }


inForm : Form.Run RegistrationForm.Model RegistrationForm.Msg Model Msg
inForm =
    Form.run FormMsg


init : Flags -> ( Model, Cmd Msg )
init () =
    save Model
        |> andMap (mapCmd FormMsg RegistrationForm.init)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FormMsg formMsg ->
            model
                |> inForm (Form.update formMsg { onSubmit = always save })


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view _ =
    { title = ""
    , body =
        [ div [] []
        , div [] []
        ]
    }


main : Program Flags Model Msg
main =
    document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
