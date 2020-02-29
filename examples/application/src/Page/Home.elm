module Page.Home exposing (..)

import Data.Post as Post exposing (Post)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Maybe.Extra as Maybe
import Recipes.Api as Api exposing (Resource(..), apiDefaultHandlers, insertAsApiIn, sendEmptyRequest)
import Recipes.Api.Json as JsonApi
import Update.Pipeline exposing (andMap, andThen, mapCmd, save)
import Update.Pipeline.Extended exposing (Extended, Run, runStack, runStackE)


type Msg
    = ApiMsg (Api.Msg (List Post))


type alias Model =
    { posts : Api.Model (List Post)
    }


insertAsPostsIn : Model -> Api.Model (List Post) -> ( Model, Cmd msg )
insertAsPostsIn model posts =
    save { model | posts = posts }


inPostsApi : Run Model (Api.Model (List Post)) Msg (Api.Msg (List Post)) a
inPostsApi =
    runStack .posts insertAsPostsIn ApiMsg


inPostsApiE : Run (Extended Model b) (Api.Model (List Post)) Msg (Api.Msg (List Post)) a
inPostsApiE =
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
    in
    save Model
        |> andMap (mapCmd ApiMsg api)
        |> andThen (inPostsApi sendEmptyRequest)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


update :
    Msg
    -> b
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
update msg _ =
    case msg of
        ApiMsg apiMsg ->
            inPostsApiE (Api.update apiMsg apiDefaultHandlers)


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
            div []
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
    div []
        (case posts.resource of
            NotRequested ->
                []

            Requested ->
                [ text "Loading" ]

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
