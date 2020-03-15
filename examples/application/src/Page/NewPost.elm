module Page.NewPost exposing (..)

import Data.Post as Post exposing (Post)
import Form.NewPost
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import Recipes.Api as Api exposing (Resource(..), apiDefaultHandlers, insertAsApiIn)
import Recipes.Api.Json as JsonApi
import Recipes.Form as Form exposing (insertAsFormIn)
import Ui.Page
import Update.Pipeline exposing (andMap, save)
import Update.Pipeline.Extended exposing (Extended, Run, andCall, call)
import Util.Api


type Msg
    = ApiMsg (Api.Msg Post)
    | FormMsg Form.NewPost.Msg


type alias Model =
    { api : Api.Model Post
    , form : Form.NewPost.Model
    }


inForm : Run (Extended Model c) Form.NewPost.Model Msg Form.NewPost.Msg f
inForm =
    Form.runExtended FormMsg


inApi : Run (Extended Model c) (Api.Model Post) Msg (Api.Msg Post) f
inApi =
    Api.runExtended ApiMsg


init : () -> ( Model, Cmd Msg )
init () =
    let
        api =
            JsonApi.init
                { endpoint = "/posts"
                , method = Api.HttpPost
                , decoder = Json.field "post" Post.decoder
                , headers = []
                }
    in
    save Model
        |> andMap api
        |> andMap (Form.NewPost.init [])


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


handleSubmit :
    Form.NewPost.Data
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
handleSubmit =
    Form.NewPost.toJson >> JsonApi.sendJson "" >> inApi


update :
    Msg
    -> { c | onPostAdded : Post -> a }
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
update msg { onPostAdded } =
    case msg of
        ApiMsg apiMsg ->
            let
                handlePostAdded post =
                    call (onPostAdded post)
            in
            inApi
                (Api.update apiMsg
                    { apiDefaultHandlers | onSuccess = handlePostAdded }
                )

        FormMsg formMsg ->
            inForm (Form.update formMsg { onSubmit = handleSubmit })


view : Model -> Html Msg
view { api, form } =
    Ui.Page.container "New post"
        [ case api.resource of
            Error error ->
                Util.Api.requestErrorMessage error

            _ ->
                text ""
        , Html.map FormMsg (Form.NewPost.view form)
        ]
