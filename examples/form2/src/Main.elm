module Main exposing (..)

import Browser exposing (Document, document)
import Form.Register as RegistrationForm
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Recipes.Form as Form
import Update.Pipeline exposing (..)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, parse)


type alias Flags =
    ()


type Msg
    = FormMsg RegistrationForm.Msg


type alias Model =
    { form : RegistrationForm.Model
    , data : Maybe RegistrationForm.Data
    }


setData : Maybe RegistrationForm.Data -> Model -> ( Model, Cmd msg )
setData maybeData model =
    save { model | data = maybeData }


inForm : Form.Bundle RegistrationForm.Model RegistrationForm.Msg Model Msg -> Model -> ( Model, Cmd Msg )
inForm =
    Form.run FormMsg


init : Flags -> ( Model, Cmd Msg )
init () =
    save Model
        |> andMap (mapCmd FormMsg RegistrationForm.init)
        |> andMap (save Nothing)


handleSubmit : RegistrationForm.Data -> Model -> ( Model, Cmd Msg )
handleSubmit data model =
    model
        |> setData (Just data)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FormMsg formMsg ->
            model
                |> inForm (Form.update formMsg { onSubmit = handleSubmit })


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view { form, data } =
    { title = ""
    , body =
        [ case data of
            Just { name } ->
                p [] [ text ("Thanks for registering " ++ name) ]

            Nothing ->
                Html.map FormMsg (RegistrationForm.view form)
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
