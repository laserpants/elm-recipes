module Page.NewPost exposing (..)

import Form.NewPost
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Recipes.Form as Form exposing (insertAsFormIn)
import Update.Pipeline exposing (andMap, mapCmd, save)
import Update.Pipeline.Extended exposing (Extended, Run, andCall, call, runStackE)


type Msg
    = FormMsg Form.NewPost.Msg


type alias Model =
    { form : Form.NewPost.Model
    }


inForm : Run (Extended Model c) Form.NewPost.Model Msg Form.NewPost.Msg f
inForm =
    runStackE .form insertAsFormIn FormMsg


init : {} -> ( Model, Cmd Msg )
init {} =
    let
        form =
            Form.NewPost.init []
    in
    save Model
        |> andMap (mapCmd FormMsg form)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


handleSubmit :
    Form.NewPost.Data
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
handleSubmit _ =
    save


update :
    Msg
    -> { onAuthResponse : b }
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
update msg {} =
    case msg of
        FormMsg formMsg ->
            inForm (Form.update formMsg { onSubmit = handleSubmit })


view : Model -> Html Msg
view { form } =
    div []
        [ Html.map FormMsg (Form.NewPost.view form)
        ]
