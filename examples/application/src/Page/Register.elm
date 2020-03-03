module Page.Register exposing (..)

import Data.User as User exposing (User)
import WebSocket.UsernameAvailable as UsernameAvailable
import Dict
import Form.Error exposing (Error(..))
import Form.Register exposing (Field(..), UsernameStatus(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Json.Encode as Encode
import Recipes.Api as Api exposing (Resource(..), apiDefaultHandlers, insertAsApiIn)
import Recipes.Api.Json as JsonApi
import Recipes.Form as Form exposing (insertAsFormIn)
import Recipes.WebSocket as WebSocket
import Set exposing (Set)
import Update.Pipeline exposing (andAddCmd, andMap, andThen, andThenIf, mapCmd, save, using, when)
import Update.Pipeline.Extended exposing (Extended, Run, andCall, call, choosing, lift, runStack, runStackE)


type Msg
    = ApiMsg (Api.Msg User)
    | FormMsg Form.Register.Msg
    | WebSocketMsg (Result WebSocket.Error Msg)
    | UsernameAvailableWsResponseMsg UsernameAvailable.WsResponse


type alias Model =
    { api : Api.Model User
    , form : Form.Register.Model
    , unavailableNames : Set String
    , websocket : WebSocket.MessageHandler Msg
    }


inApi : Run (Extended Model b) (Api.Model User) Msg (Api.Msg User) a
inApi =
    runStackE .api insertAsApiIn ApiMsg


inForm : Run Model Form.Register.Model Msg Form.Register.Msg a
inForm =
    runStack .form insertAsFormIn FormMsg


inFormE : Run (Extended Model b) Form.Register.Model Msg Form.Register.Msg a
inFormE =
    runStackE .form insertAsFormIn FormMsg


setUsernameStatus : UsernameStatus -> Model -> ( Model, Cmd Msg )
setUsernameStatus =
    inForm << Form.setState


setUsernameUnavailable : String -> Model -> ( Model, Cmd Msg )
setUsernameUnavailable username state =
    save { state | unavailableNames = Set.insert username state.unavailableNames }


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

        websocket =
            WebSocket.init
                |> andThen (WebSocket.insertHandler
                      UsernameAvailableWsResponseMsg
                      UsernameAvailable.responseId
                      UsernameAvailable.responseDecoder)
    in
    save Model
        |> andMap (mapCmd ApiMsg api)
        |> andMap (mapCmd FormMsg form)
        |> andMap (save Set.empty)
        |> andMap websocket


subscriptions : Model -> Sub Msg
subscriptions { websocket } =
    Sub.map WebSocketMsg (WebSocket.subscriptions websocket)


handleSubmit :
    Form.Register.Data
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
handleSubmit =
    Form.Register.toJson >> JsonApi.sendJson "" >> inApi


validateUsernameField :
    Extended (Form.ModelState Form.Register.Field e d s) a
    -> ( Extended (Form.ModelState Form.Register.Field e d s) a, Cmd Form.Register.Msg )
validateUsernameField =
    Form.validateField Username
        >> andThen (Form.setFieldDirty Username False)


checkIfUsernameAvailable :
    String
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
checkIfUsernameAvailable name =
    choosing
        (\{ unavailableNames } ->
            let
                setStatus =
                    lift << setUsernameStatus
            in
            if String.isEmpty name then
                setStatus Blank

            else if Set.member name unavailableNames then
                setStatus (IsAvailable False)
                    >> andThen (inFormE validateUsernameField)

            else
                setStatus Unknown
                    >> andThen (UsernameAvailable.sendRequest { username = name })
        )


update :
    Msg
    -> { b | onRegistrationComplete : User -> a }
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
update msg ({ onRegistrationComplete } as callbacks) =
    case msg of
        ApiMsg apiMsg ->
            let
                handleSuccess user =
                    call (onRegistrationComplete user)

                handlers =
                    { apiDefaultHandlers | onSuccess = handleSuccess }
            in
            inApi (Api.update apiMsg handlers)

        FormMsg formMsg ->
            inFormE (Form.update formMsg { onSubmit = handleSubmit })
                >> andThen
                    (case formMsg of
                        Form.Input Username username ->
                            checkIfUsernameAvailable (Form.asString username)

                        _ ->
                            save
                    )

        WebSocketMsg ws ->
            WebSocket.updateExtendedModel update callbacks ws

        UsernameAvailableWsResponseMsg { username, isAvailable } ->
            choosing
                (\{ form } ->
                    let
                        fieldValue =
                            form.fields
                                |> Form.field Username
                                |> Form.stringValue
                    in
                    when (username == fieldValue)
                        (lift (setUsernameStatus (IsAvailable isAvailable)))
                )
                >> andThenIf (not isAvailable)
                    (lift (setUsernameUnavailable username))
                >> andThen (inFormE validateUsernameField)


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
