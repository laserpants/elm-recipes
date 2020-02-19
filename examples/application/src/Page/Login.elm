module Page.Login exposing (..)

import Form.Login
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Recipes.Form as Form exposing (insertAsFormIn)
import Update.Pipeline exposing (andMap, mapCmd, save)
import Update.Pipeline.Extended exposing (Extended, Run, runStackE)


type Msg
    = FormMsg Form.Login.Msg


type alias Model =
    { form : Form.Login.Model
    }


insertAsFormIn : Model -> Form.Login.Model -> ( Model, Cmd Msg )
insertAsFormIn model form =
    save { model | form = form }


inForm : Run (Extended Model c) Form.Login.Model Msg Form.Login.Msg f
inForm =
    runStackE .form insertAsFormIn FormMsg


init : {} -> ( Model, Cmd Msg )
init {} =
    save Model
        |> andMap (mapCmd FormMsg Form.Login.init)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


update : Msg -> {} -> Extended Model a -> ( Extended Model a, Cmd Msg )
update msg {} model =
    case msg of
        FormMsg formMsg ->
            model
                |> inForm (Form.update formMsg { onSubmit = always save })


view : Model -> Html Msg
view { form } =
    div []
        [ Html.map FormMsg (Form.Login.view form)
        ]
