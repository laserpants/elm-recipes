module Page.Register exposing (..)

import Form.Register
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Recipes.Form as Form exposing (insertAsFormIn)
import Update.Pipeline exposing (andMap, mapCmd, save)
import Update.Pipeline.Extended exposing (Extended, Run, andCall, call, runStackE)


type Msg
    = FormMsg Form.Register.Msg


type alias Model =
    { form : Form.Register.Model
    }


inForm : Run (Extended Model c) Form.Register.Model Msg Form.Register.Msg f
inForm =
    runStackE .form insertAsFormIn FormMsg


init : () -> ( Model, Cmd Msg )
init () =
    let
        form =
            Form.Register.init []
    in
    save Model
        |> andMap (mapCmd FormMsg form)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


handleSubmit :
    Form.Register.Data
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
handleSubmit formData =
    save


update :
    Msg
    -> b
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
update msg _ =
    case msg of
        FormMsg formMsg ->
            inForm (Form.update formMsg { onSubmit = handleSubmit })


view : Model -> Html Msg
view { form } =
    div []
        [ Html.map FormMsg (Form.Register.view form)
        ]
