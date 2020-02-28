module Page.NewPost exposing (..)

import Data.Post as Post exposing (Post)
import Form.NewPost
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import Recipes.Api as Api exposing (apiDefaultHandlers, insertAsApiIn)
import Recipes.Api.Json as JsonApi
import Recipes.Form as Form exposing (insertAsFormIn)
import Update.Pipeline exposing (andMap, mapCmd, save)
import Update.Pipeline.Extended exposing (Extended, Run, andCall, call, runStackE)


type Msg
    = ApiMsg (Api.Msg Post)
    | FormMsg Form.NewPost.Msg


type alias Model =
    { form : Form.NewPost.Model
    , api : Api.Model Post
    }


inForm : Run (Extended Model c) Form.NewPost.Model Msg Form.NewPost.Msg f
inForm =
    runStackE .form insertAsFormIn FormMsg


inApi : Run (Extended Model c) (Api.Model Post) Msg (Api.Msg Post) f
inApi =
    runStackE .api insertAsApiIn ApiMsg


init : () -> ( Model, Cmd Msg )
init () =
    let
        form =
            Form.NewPost.init []

        api =
            JsonApi.init
                { endpoint = "/posts"
                , method = Api.HttpPost
                , decoder = Json.field "post" Post.decoder
                , headers = []
                }
    in
    save Model
        |> andMap (mapCmd FormMsg form)
        |> andMap (mapCmd ApiMsg api)


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
    ->
        { onAuthResponse : b
        , onAddPost : Post -> a
        }
    -> Extended Model a
    -> ( Extended Model a, Cmd Msg )
update msg { onAddPost } =
    case msg of
        ApiMsg apiMsg ->
            inApi
                (Api.update apiMsg
                    { apiDefaultHandlers | onSuccess = \post -> call (onAddPost post) }
                )

        FormMsg formMsg ->
            inForm (Form.update formMsg { onSubmit = handleSubmit })


view : Model -> Html Msg
view { form } =
    div []
        [ Html.map FormMsg (Form.NewPost.view form)
        ]
