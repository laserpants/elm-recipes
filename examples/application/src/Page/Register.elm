module Page.Register exposing (..)

import Bulma.Columns exposing (columnModifiers, columnsModifiers)
import Bulma.Components exposing (card, cardContent)
import Data.User as User exposing (User)
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
import Update.Pipeline exposing (andAddCmd, andMap, andThen, andThenIf, save, using, when)
import Update.Pipeline.Extended exposing (Extended, Run, andCall, call, choosing, lift, runStack)
import Util.Api
import WebSocket.UsernameAvailable as UsernameAvailable


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
    Api.runExtended ApiMsg


inForm : Run (Extended Model b) Form.Register.Model Msg Form.Register.Msg a
inForm =
    Form.runExtended FormMsg


setUsernameStatus : UsernameStatus -> Extended Model a -> ( Extended Model a, Cmd Msg )
setUsernameStatus =
    inForm << Form.setState


setUsernameUnavailable : String -> Extended Model a -> ( Extended Model a, Cmd Msg )
setUsernameUnavailable username ( state, calls ) =
    save ( { state | unavailableNames = Set.insert username state.unavailableNames }, calls )


init : () -> ( Model, Cmd Msg )
init () =
    let
        api =
            JsonApi.init
                { endpoint = "/auth/register"
                , method = Api.HttpPost
                , decoder = Json.field "user" User.decoder
                , headers = []
                }

        websocket =
            WebSocket.init
                |> andThen
                    (WebSocket.createHandler
                        UsernameAvailableWsResponseMsg
                        UsernameAvailable.responseId
                        UsernameAvailable.responseDecoder
                    )
    in
    save Model
        |> andMap api
        |> andMap (Form.Register.init [])
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
checkIfUsernameAvailable username =
    choosing
        (\{ unavailableNames } ->
            let
                setStatus =
                    setUsernameStatus
            in
            if String.isEmpty username then
                setStatus Blank

            else if Set.member username unavailableNames then
                setStatus (IsAvailable False)
                    >> andThen (inForm validateUsernameField)

            else
                setStatus Unknown
                    >> andThen (UsernameAvailable.sendRequest { username = username })
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
            inForm (Form.update formMsg { onSubmit = handleSubmit })
                >> andThen
                    (case formMsg of
                        Form.Input Username username ->
                            checkIfUsernameAvailable (Form.asString username)

                        _ ->
                            save
                    )

        WebSocketMsg ws ->
            WebSocket.updateModelExtended Nothing update callbacks ws

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
                        (setUsernameStatus (IsAvailable isAvailable))
                )
                >> andThenIf (not isAvailable)
                    (setUsernameUnavailable username)
                >> andThen (inForm validateUsernameField)


view : Model -> Html Msg
view { api, form } =
    Bulma.Columns.columns
        { columnsModifiers | centered = True }
        [ style "margin" "3em"
        ]
        [ Bulma.Columns.column
            columnModifiers
            [ class "is-half" ]
            [ card []
                [ cardContent []
                    [ h3
                        [ class "title is-3" ]
                        [ text "Register" ]
                    , case api.resource of
                        Error error ->
                            Util.Api.requestErrorMessage error

                        _ ->
                            text ""
                    , Html.map FormMsg (Form.Register.view form)
                    ]
                ]
            ]
        ]
