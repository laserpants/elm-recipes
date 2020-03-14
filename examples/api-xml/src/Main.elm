module Main exposing (..)

import Browser exposing (Document, document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json exposing (field)
import Recipes.Api as Api exposing (..)
import Recipes.Api.Xml as XmlApi
import Update.Pipeline exposing (andMap, mapCmd, save)
import Xml.Decode as Xml


type alias Book =
    { id : Maybe Int
    , title : String
    , author : String
    , synopsis : String
    }


bookDecoder : Xml.Decoder Book
bookDecoder =
    Xml.path [ "book" ]
        (Xml.single
            (Xml.map4 Book
                (Xml.path [ "id" ] (Xml.single (Xml.maybe Xml.int)))
                (Xml.path [ "title" ] (Xml.single Xml.string))
                (Xml.path [ "author" ] (Xml.single Xml.string))
                (Xml.path [ "synopsis" ] (Xml.single Xml.string))
            )
        )


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
        api =
            XmlApi.init
                { endpoint = "/books/1"
                , method = HttpGet
                , decoder = bookDecoder
                , headers = []
                }
    in
    save Model
        |> andMap (mapCmd ApiMsg api)


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
