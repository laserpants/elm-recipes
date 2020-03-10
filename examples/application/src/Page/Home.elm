module Page.Home exposing (..)

import Bulma.Elements exposing (content)
import Bulma.Modifiers exposing (Size(..))
import Data.Post as Post exposing (Post)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Json.Encode as Encode
import Maybe.Extra as Maybe
import Recipes.Api as Api exposing (Resource(..), apiDefaultHandlers, insertAsApiIn, sendEmptyRequest)
import Recipes.Api.Json as JsonApi
import Recipes.WebSocket as WebSocket
import Ui exposing (spinner)
import Ui.Page
import Update.Pipeline exposing (andMap, andThen, mapCmd, save)
import Update.Pipeline.Extended exposing (Extended, Run, runStack, runStackE)
import WebSocket.Ping as Ping


type Msg
    = ApiMsg (Api.Msg (List Post))
    | WebSocketMsg (Result WebSocket.Error Msg)
    | SendPing
    | PingWsResponseMsg Ping.WsResponse


type alias Model =
    { posts : Api.Model (List Post)
    , websocket : WebSocket.MessageHandler Msg
    }


insertAsPostsIn : Model -> Api.Model (List Post) -> ( Model, Cmd msg )
insertAsPostsIn model posts =
    save { model | posts = posts }


inPostsApi : Run (Extended Model b) (Api.Model (List Post)) Msg (Api.Msg (List Post)) a
inPostsApi =
    runStackE .posts insertAsPostsIn ApiMsg


init : () -> ( Model, Cmd Msg )
init () =
    let
        api =
            JsonApi.init
                { endpoint = "/posts"
                , method = Api.HttpGet
                , decoder = Json.field "posts" (Json.list Post.decoder)
                , headers = []
                }

        websocket =
            WebSocket.init
                |> andThen
                    (WebSocket.createHandler
                        PingWsResponseMsg
                        Ping.responseId
                        Ping.responseDecoder
                    )

        inPosts =
            runStack .posts insertAsPostsIn
    in
    save Model
        |> andMap (mapCmd ApiMsg api)
        |> andMap websocket
        |> andThen (inPosts ApiMsg sendEmptyRequest)


subscriptions : Model -> Sub Msg
subscriptions { websocket } =
    Sub.map WebSocketMsg (WebSocket.subscriptions websocket)


update :
    Msg
    -> b
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
update msg callbacks =
    case msg of
        ApiMsg apiMsg ->
            inPostsApi (Api.update apiMsg apiDefaultHandlers)

        WebSocketMsg ws ->
            WebSocket.updateExtendedModel update callbacks ws

        SendPing ->
            Ping.send

        PingWsResponseMsg { message } ->
            Debug.log message save


view : Model -> Html Msg
view { posts } =
    let
        listItem { id, comments, title, body } =
            let
                postUrl =
                    "/posts/" ++ String.fromInt id

                commentsLink =
                    if List.isEmpty comments then
                        text "No comments"

                    else
                        let
                            len =
                                List.length comments
                        in
                        a [ href postUrl ]
                            [ text
                                (if 1 == len then
                                    "1 comment"

                                 else
                                    String.fromInt len ++ " comments"
                                )
                            ]
            in
            content Standard
                []
                [ h4
                    [ class "title is-4" ]
                    [ a [ href postUrl ]
                        [ text title ]
                    ]
                , p [] [ text body ]
                , p []
                    [ i
                        [ class "fa fa-comments"
                        , style "margin-right" ".5em"
                        ]
                        []
                    , commentsLink
                    ]
                ]
    in
    Ui.Page.container "Posts"
        (case posts.resource of
            NotRequested ->
                []

            Requested ->
                [ div
                    [ style "display" "flex"
                    , style "flex-direction" "row"
                    , style "justify-content" "center"
                    , style "margin" "4em"
                    ]
                    [ spinner
                    ]
                ]

            Error error ->
                [ text (Debug.toString error) ]

            Available items ->
                let
                    maybeItem { id, title, body, comments } =
                        case id of
                            Just id_ ->
                                Just
                                    { id = id_
                                    , title = title
                                    , body = body
                                    , comments = comments
                                    }

                            Nothing ->
                                Nothing
                in
                items
                    |> List.map maybeItem
                    |> Maybe.values
                    |> List.map listItem
        )
