module Page.ShowPost exposing (..)

import Data.Comment as Comment exposing (Comment)
import Data.Post as Post exposing (Post)
import Form.Comment
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import Recipes.Api as Api exposing (Resource(..), apiDefaultHandlers, insertAsApiIn, sendEmptyRequest, withResource)
import Recipes.Api.Json as JsonApi
import Recipes.Form as Form
import Ui exposing (spinner)
import Ui.Page
import Update.Pipeline exposing (andMap, andThen, save)
import Update.Pipeline.Extended exposing (Extended, Run, andCall, runStack, runStackExtended)
import Util.Api


type Msg
    = PostApiMsg (Api.Msg Post)
    | CommentApiMsg (Api.Msg Comment)
    | CommentFormMsg Form.Comment.Msg
    | FetchPost


type alias Model =
    { id : Int
    , postApi : Api.Model Post
    , commentApi : Api.Model Comment
    , commentForm : Form.Comment.Model
    }


insertAsPostApiIn : Model -> Api.Model Post -> ( Model, Cmd msg )
insertAsPostApiIn model postApi =
    save { model | postApi = postApi }


insertAsCommentApiIn : Model -> Api.Model Comment -> ( Model, Cmd msg )
insertAsCommentApiIn model commentApi =
    save { model | commentApi = commentApi }


insertAsCommentFormIn : Model -> Form.Comment.Model -> ( Model, Cmd msg )
insertAsCommentFormIn model commentForm =
    save { model | commentForm = commentForm }


inPostApi : Run (Extended Model b) (Api.Model Post) Msg (Api.Msg Post) a
inPostApi =
    runStackExtended .postApi insertAsPostApiIn PostApiMsg


inCommentApi : Run (Extended Model b) (Api.Model Comment) Msg (Api.Msg Comment) a
inCommentApi =
    runStackExtended .commentApi insertAsCommentApiIn CommentApiMsg


inCommentForm : Run (Extended Model b) Form.Comment.Model Msg Form.Comment.Msg a
inCommentForm =
    runStackExtended .commentForm insertAsCommentFormIn CommentFormMsg


init : Int -> ( Model, Cmd Msg )
init id =
    let
        postApi =
            JsonApi.init
                { endpoint = "/posts/" ++ String.fromInt id
                , method = Api.HttpGet
                , decoder = Json.field "post" Post.decoder
                , headers = []
                }

        commentApi =
            JsonApi.init
                { endpoint = "/posts/" ++ String.fromInt id ++ "/comments"
                , method = Api.HttpPost
                , decoder = Json.field "comment" Comment.decoder
                , headers = []
                }

        inPost =
            runStack .postApi insertAsPostApiIn
    in
    save Model
        |> andMap (save id)
        |> andMap postApi
        |> andMap commentApi
        |> andMap (Form.Comment.init [])
        |> andThen (inPost PostApiMsg sendEmptyRequest)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


handleSubmit :
    Form.Comment.Data
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
handleSubmit =
    Form.Comment.toJson >> JsonApi.sendJson "" >> inCommentApi


insertComment :
    Comment
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
insertComment comment =
    let
        insert post =
            { post | comments = comment :: post.comments }
    in
    inPostApi (withResource insert)


update :
    Msg
    -> { b | onCommentCreated : Comment -> a }
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
update msg { onCommentCreated } =
    case msg of
        PostApiMsg apiMsg ->
            inPostApi (Api.update apiMsg apiDefaultHandlers)

        CommentApiMsg apiMsg ->
            let
                commentCreated comment =
                    inCommentForm Form.reset
                        >> andThen (insertComment comment)
                        >> andCall (onCommentCreated comment)
            in
            inCommentApi
                (Api.update apiMsg
                    { apiDefaultHandlers | onSuccess = commentCreated }
                )

        CommentFormMsg formMsg ->
            inCommentForm
                (Form.update formMsg
                    { onSubmit = handleSubmit
                    }
                )

        FetchPost ->
            inPostApi sendEmptyRequest


view : Model -> Html Msg
view { postApi, commentApi, commentForm } =
    let
        loading =
            Requested == postApi.resource || commentForm.disabled

        commentItem { email, body } =
            [ p
                [ style "margin-bottom" ".5em" ]
                [ b
                    []
                    [ text "From: "
                    ]
                , text email
                ]
            , p [] [ text body ]
            , hr [] []
            ]

        subtitle title =
            h5
                [ class "title is-5"
                , style "margin-top" "1.5em"
                ]
                [ text title ]

        postView =
            case postApi.resource of
                Error error ->
                    case error of
                        Http.BadStatus 404 ->
                            [ h3 [ class "title is-3" ] [ text "Page not found" ]
                            , p [] [ text "That post doesn’t exist." ]
                            ]

                        _ ->
                            [ Util.Api.requestErrorMessage error ]

                Available { title, body, comments } ->
                    [ h3 [ class "title is-3" ] [ text title ]
                    , p [] [ text body ]
                    , hr [] []
                    , subtitle "Comments"
                    , div []
                        (if List.isEmpty comments then
                            [ p [] [ text "No comments" ] ]

                         else
                            List.concatMap commentItem comments
                        )
                    , subtitle "Leave a comment"
                    , case commentApi.resource of
                        Error error ->
                            Util.Api.requestErrorMessage error

                        _ ->
                            text ""
                    , Html.map CommentFormMsg (Form.Comment.view commentForm)
                    ]

                _ ->
                    []
    in
    Ui.Page.layout
        (if loading then
            [ div
                [ style "display" "flex"
                , style "flex-direction" "row"
                , style "justify-content" "center"
                , style "margin" "4em"
                ]
                [ spinner
                ]
            ]

         else
            postView
        )
