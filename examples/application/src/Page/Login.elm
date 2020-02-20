module Page.Login exposing (..)

import Data.Session as Session exposing (Session)
import Form.Login
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import Recipes.Api as Api exposing (apiDefaultHandlers)
import Recipes.Api.Json as JsonApi
import Recipes.Form as Form exposing (insertAsFormIn)
import Update.Pipeline exposing (andMap, mapCmd, save)
import Update.Pipeline.Extended exposing (Extended, Run, andCall, call, runStackE)


type Msg
    = ApiMsg (Api.Msg Session)
    | FormMsg Form.Login.Msg


type alias Model =
    { api : Api.Model Session
    , form : Form.Login.Model
    }


insertAsApiIn : Model -> Api.Model Session -> ( Model, Cmd Msg )
insertAsApiIn model api =
    save { model | api = api }


insertAsFormIn : Model -> Form.Login.Model -> ( Model, Cmd Msg )
insertAsFormIn model form =
    save { model | form = form }


inApi : Run (Extended Model c) (Api.Model Session) Msg (Api.Msg Session) f
inApi =
    runStackE .api insertAsApiIn ApiMsg


inForm : Run (Extended Model c) Form.Login.Model Msg Form.Login.Msg f
inForm =
    runStackE .form insertAsFormIn FormMsg


init : {} -> ( Model, Cmd Msg )
init {} =
    let
        api =
            JsonApi.init
                { endpoint = "/auth/login"
                , method = Api.HttpPost
                , decoder = Json.field "session" Session.decoder
                , headers = []
                }

        form =
             Form.Login.init []
    in
    save Model
        |> andMap (mapCmd ApiMsg api)
        |> andMap (mapCmd FormMsg form)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


handleSubmit :
    Form.Login.Data
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
handleSubmit formData =
    let
        json =
            Http.jsonBody (Form.Login.toJson formData)
    in
    inApi (Api.sendRequest "" (Just json))


update :
    Msg
    -> { onAuthResponse : Maybe Session -> a }
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
update msg { onAuthResponse } =
    let
        respondWith response =
            inForm Form.reset
                >> andCall (onAuthResponse response)

        handleSuccess session =
            respondWith (Just session)

        handleError _ =
            respondWith Nothing
    in
    case msg of
        ApiMsg apiMsg ->
            inApi
                (Api.update apiMsg
                    { onSuccess = handleSuccess
                    , onError = handleError
                    }
                )

        FormMsg formMsg ->
            inForm (Form.update formMsg { onSubmit = handleSubmit })


view : Model -> Html Msg
view { form } =
    div []
        [ Html.map FormMsg (Form.Login.view form)
        ]
