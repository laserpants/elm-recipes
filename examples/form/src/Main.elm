module Main exposing (..)

import Browser exposing (Document, document)
import Form.Data.Register as RegisterForm
import Form.Register as RegisterForm exposing (Fields(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Recipes.Form as Form
import Update.Pipeline exposing (..)
import Update.Pipeline.Extended exposing (Run)


type alias Flags =
    ()


type Msg
    = FormMsg RegisterForm.Msg


type alias Model =
    { form : RegisterForm.Model
    , data : Maybe RegisterForm.Data
    }


setData : Maybe RegisterForm.Data -> Model -> ( Model, Cmd msg )
setData maybeData model =
    save { model | data = maybeData }


inForm : Run Model RegisterForm.Model Msg RegisterForm.Msg a
inForm =
    Form.run FormMsg


init : Flags -> ( Model, Cmd Msg )
init () =
    save Model
        |> andMap RegisterForm.init
        |> andMap (save Nothing)


handleSubmit : RegisterForm.Data -> Model -> ( Model, Cmd Msg )
handleSubmit data model =
    model
        |> setData (Just data)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FormMsg formMsg ->
            model
                |> inForm (Form.update formMsg { onSubmit = handleSubmit })
                |> andThen
                    (case formMsg of
                        Form.Input Password value ->
                            inForm (Form.validateField PasswordConfirmation)

                        _ ->
                            save
                    )


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
                Html.map FormMsg (RegisterForm.view form)
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
