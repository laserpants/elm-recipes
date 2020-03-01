module Page.Register exposing (..)

import Data.User as User exposing (User)
import Data.Websocket.UsernameAvailableResponse as UsernameAvailableResponse exposing (UsernameAvailableResponse)
import Form.Error exposing (Error(..))
import Form.Register exposing (Field(..), UsernameStatus(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Json.Encode as Encode
import Page.Register.Ports as Ports
import Recipes.Api as Api exposing (Resource(..), apiDefaultHandlers, insertAsApiIn)
import Recipes.Api.Json as JsonApi
import Recipes.Form as Form exposing (insertAsFormIn)
import Set exposing (Set)
import Update.Pipeline exposing (andAddCmd, andMap, andThen, andThenIf, mapCmd, save, using, when)
import Update.Pipeline.Extended exposing (Extended, Run, andCall, call, lift, runStack, runStackE)
import Util exposing (choosing)


type WebSocketMessage
    = WsUsernameAvailable UsernameAvailableResponse


websocketMessageDecoder : Json.Decoder WebSocketMessage
websocketMessageDecoder =
    let
        payloadDecoder messageType =
            case messageType of
                "username_available_response" ->
                    Json.map WsUsernameAvailable UsernameAvailableResponse.decoder

                _ ->
                    Json.fail "Unrecognized message type"
    in
    Json.field "type" Json.string
        |> Json.andThen payloadDecoder


type Msg
    = ApiMsg (Api.Msg User)
    | FormMsg Form.Register.Msg
    | WebsocketMsg String


type alias Model =
    { api : Api.Model User
    , form : Form.Register.Model
    , unavailableNames : Set String
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
    in
    save Model
        |> andMap (mapCmd ApiMsg api)
        |> andMap (mapCmd FormMsg form)
        |> andMap (save Set.empty)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Ports.websocketIn WebsocketMsg


handleSubmit :
    Form.Register.Data
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
handleSubmit =
    Form.Register.toJson >> JsonApi.sendJson "" >> inApi


usernameIsAvailableQuery : String -> Json.Value
usernameIsAvailableQuery username =
    Encode.object
        [ ( "type", Encode.string "username_available_query" )
        , ( "username", Encode.string username )
        ]


validateUsernameField :
    Extended Model a
    -> ( Extended Model a, Cmd Msg )
validateUsernameField =
    inFormE
        (Form.validateField Username
            >> andThen (Form.setFieldDirty Username False)
        )


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
                    >> andThen validateUsernameField

            else
                let
                    encodedMsg =
                        Encode.encode 0 (usernameIsAvailableQuery name)
                in
                setStatus Unknown
                    >> andAddCmd (Ports.websocketOut encodedMsg)
        )


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

        WebsocketMsg wsMsg ->
            case Json.decodeString websocketMessageDecoder wsMsg of
                Ok (WsUsernameAvailable { username, available }) ->
                    choosing
                        (\{ form } ->
                            let
                                fieldValue =
                                    form.fields
                                        |> Form.field Username
                                        |> Form.stringValue
                            in
                            when (username == fieldValue)
                                (lift (setUsernameStatus (IsAvailable available)))
                        )
                        >> andThenIf (not available)
                            (lift (setUsernameUnavailable username))
                        >> andThen validateUsernameField

                _ ->
                    save


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
