module Page.Login exposing (..)

import Bulma.Columns exposing (columnsModifiers, narrowColumnModifiers)
import Bulma.Components exposing (card, cardContent, message, messageBody, messageModifiers)
import Bulma.Modifiers exposing (Color(..))
import Data.Session as Session exposing (Session)
import Form.Login
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import Recipes.Api as Api exposing (Resource(..), apiDefaultHandlers, insertAsApiIn)
import Recipes.Api.Json as JsonApi
import Recipes.Form as Form exposing (insertAsFormIn)
import Update.Pipeline exposing (andMap, save)
import Update.Pipeline.Extended exposing (Extended, Run, andCall, call)
import Util.Api


type Msg
    = ApiMsg (Api.Msg Session)
    | FormMsg Form.Login.Msg


type alias Model =
    { api : Api.Model Session
    , form : Form.Login.Model
    }


inApi : Run (Extended Model c) (Api.Model Session) Msg (Api.Msg Session) f
inApi =
    Api.runExtended ApiMsg


inForm : Run (Extended Model c) Form.Login.Model Msg Form.Login.Msg f
inForm =
    Form.runExtended FormMsg


init : () -> ( Model, Cmd Msg )
init () =
    let
        api =
            JsonApi.init
                { endpoint = "/auth/login"
                , method = Api.HttpPost
                , decoder = Json.field "session" Session.decoder
                , headers = []
                }
    in
    save Model
        |> andMap api
        |> andMap (Form.Login.init [])


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


handleSubmit :
    Form.Login.Data
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
handleSubmit =
    Form.Login.toJson >> JsonApi.sendJson "" >> inApi


update :
    Msg
    -> { c | onAuthResponse : Maybe Session -> a }
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
update msg { onAuthResponse } =
    case msg of
        ApiMsg apiMsg ->
            let
                respondWith response =
                    inForm Form.reset
                        >> andCall (onAuthResponse response)
            in
            inApi
                (Api.update apiMsg
                    { onSuccess = \session -> respondWith (Just session)
                    , onError = always (respondWith Nothing)
                    }
                )

        FormMsg formMsg ->
            inForm (Form.update formMsg { onSubmit = handleSubmit })


view : Model -> Html Msg
view { api, form } =
    Bulma.Columns.columns
        { columnsModifiers | centered = True }
        [ class "is-mobile"
        , style "margin" "6em 0"
        ]
        [ Bulma.Columns.column
            narrowColumnModifiers
            []
            [ card []
                [ cardContent []
                    [ h3 [ class "title is-3" ] [ text "Log in" ]
                    , message { messageModifiers | color = Info }
                        [ style "max-width" "360px" ]
                        [ messageBody []
                            [ text "This is just a demo. Log in with email address 'test@test.com' and password 'test'." ]
                        ]
                    , case api.resource of
                        Error error ->
                            Util.Api.requestErrorMessage error

                        _ ->
                            text ""
                    , Html.map FormMsg (Form.Login.view form)
                    ]
                ]
            ]
        ]
