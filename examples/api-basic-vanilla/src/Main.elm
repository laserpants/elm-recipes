module Main exposing (..)

import Browser exposing (Document, document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json exposing (field)
import Recipes.Api as Api exposing (..)
import Recipes.Api.Json as JsonApi


type alias Book =
    { id : Maybe Int
    , title : String
    , author : String
    , synopsis : String
    }


bookDecoder : Json.Decoder Book
bookDecoder =
    Json.map4 Book
        (Json.maybe (field "id" Json.int))
        (field "title" Json.string)
        (field "author" Json.string)
        (field "synopsis" Json.string)


type Msg
    = ApiMsg (Api.Msg Book)
    | FetchBook
    | ResetBook


type alias Model =
    { api : Api.Model Book
    }


init : () -> ( Model, Cmd Msg )
init () =
    let
        ( apiModel, apiMsg ) =
            JsonApi.init
                { endpoint = "/books/1"
                , method = HttpGet
                , decoder = Json.field "book" bookDecoder
                , headers = []
                }
    in
    ( { api = apiModel
      }
    , Cmd.map ApiMsg apiMsg
    )


fetchBook : Model -> ( Model, Cmd Msg )
fetchBook =
    Api.run ApiMsg Api.sendEmptyRequest


resetBook : Model -> ( Model, Cmd Msg )
resetBook =
    Api.run ApiMsg Api.resetResource


update : Msg -> Model -> ( Model, Cmd Msg )
update msg =
    case msg of
        ApiMsg apiMsg ->
            Api.runUpdate ApiMsg apiMsg apiDefaultHandlers

        FetchBook ->
            fetchBook

        ResetBook ->
            resetBook


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view { api } =
    { title = "Api recipe basic example"
    , body =
        [ case api.resource of
            NotRequested ->
                div
                    []
                    [ button
                        [ onClick FetchBook ]
                        [ text "Fetch a book"
                        ]
                    ]

            Requested ->
                text "Your book is loading..."

            Available { title, synopsis } ->
                div
                    []
                    [ h2 [] [ text title ]
                    , p [] [ text synopsis ]
                    , button
                        [ onClick ResetBook ]
                        [ text "Start over again"
                        ]
                    ]

            Error _ ->
                text "That didn't work as expected."
        ]
    }


main : Program () Model Msg
main =
    document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
