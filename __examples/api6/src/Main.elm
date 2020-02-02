module Main exposing (..)

import Browser exposing (Document, document)
import Data.Book as Book exposing (Book)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Recipes.Api exposing (HttpMethod(..), Resource(..))
import Recipes.Api.Collection as Api exposing (..)
import Recipes.Api.Collection.Json as JsonApi exposing (..)
import Recipes.Helpers exposing (..)
import Update.Pipeline exposing (..)
import Url exposing (Url)


type alias Flags =
    ()


type Msg
    = BookCollectionMsg (Api.Msg Book)


type alias Model =
    { api : Api.Collection Book
    }


inApi :
    Bundle Model (Api.Collection Book) Msg (Api.Msg Book) 
    -> Model
    -> ( Model, Cmd Msg )
inApi =
    Api.run BookCollectionMsg


init : Flags -> ( Model, Cmd Msg )
init () =
    let
        collectionApi =
            JsonApi.init
                { limit = 2
                , endpoint = "/books"
                , decoder = Json.field "books" (JsonApi.envelopeDecoder "page" Book.decoder)
                , headers = []
                , queryString = Api.defaultQueryFormat
                }
    in
    save Model
        |> andMap (mapCmd BookCollectionMsg collectionApi)
        |> andThen (inApi Api.fetchPage)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BookCollectionMsg apiMsg ->
            model
                |> inApi (Api.update apiMsg)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view { api } =
    { title = ""
    , body =
        [ case api.api.resource of
            Available books ->
                let
                    row { id, title, author } =
                        tr
                            []
                            [ td [] [ text (String.fromInt id) ]
                            , td []
                                [ text title
                                ]
                            , td [] [ text author ]
                            ]
                in
                div
                    []
                    [ table [] (List.map row books.page)
                    ]

            Requested ->
                text "Loading..."

            Error err ->
                text "Something went wrong. Check the code!"

            _ ->
                text ""
        ]
    }


main : Program Flags Model Msg
main =
    document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
