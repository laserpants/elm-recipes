module Page.Register exposing (..)

import Data.User as User exposing (User)
import Form.Register
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Recipes.Api as Api exposing (Resource(..), apiDefaultHandlers, insertAsApiIn)
import Recipes.Api.Json as JsonApi
import Recipes.Form as Form exposing (insertAsFormIn)
import Update.Pipeline exposing (andMap, mapCmd, save)
import Update.Pipeline.Extended exposing (Extended, Run, andCall, call, runStackE)


type Msg
    = ApiMsg (Api.Msg User)
    | FormMsg Form.Register.Msg


type alias Model =
    { api : Api.Model User
    , form : Form.Register.Model
    }


inApi : Run (Extended Model c) (Api.Model User) Msg (Api.Msg User) f
inApi =
    runStackE .api insertAsApiIn ApiMsg


inForm : Run (Extended Model c) Form.Register.Model Msg Form.Register.Msg f
inForm =
    runStackE .form insertAsFormIn FormMsg


init : () -> ( Model, Cmd Msg )
init () =
    let
        form =
            Form.Register.init []

        api =
            JsonApi.init
                { endpoint = "/auth/register"
                , method = Api.HttpPost
                , decoder = Json.field "user" User.decoder
                , headers = []
                }
    in
    save Model
        |> andMap (mapCmd ApiMsg api)
        |> andMap (mapCmd FormMsg form)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


handleSubmit :
    Form.Register.Data
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
handleSubmit =
    Form.Register.toJson >> JsonApi.sendJson "" >> inApi


update :
    Msg
    -> { b | onRegistrationComplete : User -> a }
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
update msg { onRegistrationComplete } =
    case msg of
        ApiMsg apiMsg ->
            let
                handleSuccess user =
                    call (onRegistrationComplete user)
            in
            inApi (Api.update apiMsg { apiDefaultHandlers | onSuccess = handleSuccess })

        FormMsg formMsg ->
            inForm (Form.update formMsg { onSubmit = handleSubmit })


view : Model -> Html Msg
view { api, form } =
    div []
        [ case api.resource of
            Error error ->
                text (Debug.toString error)

            _ ->
                text ""
        , Html.map FormMsg (Form.Register.view form)
        ]
