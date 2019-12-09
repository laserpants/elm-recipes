module Main exposing (..)

import Browser exposing (Document, document)
import Html exposing (a, button, div, h2, h3, li, p, text, ul)
import Html.Attributes exposing (href)
import Html.Events exposing (..)
import Json.Decode as Json
import Update.Api as Api exposing (..)
import Update.Api.Json as JsonApi exposing (..)
import Update.Pipeline exposing (..)
import Update.Router as Router exposing (Router, forceUrlChange, handleUrlChange, handleUrlRequest)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, parse)


type alias Flags =
    ()


type alias Books =
    List Book


type Msg
    = FetchBooks
    | ShowBook Book
    | BooksApiMsg (Api.Msg Books)


type alias Book =
    { id : Int
    , title : String
    , author : String
    , synopsis : String
    }


bookDecoder : Json.Decoder Book
bookDecoder =
    Json.map4 Book
        (Json.field "id" Json.int)
        (Json.field "title" Json.string)
        (Json.field "author" Json.string)
        (Json.field "synopsis" Json.string)


type Model
    = Blank
    | BookList (Api.Model Books)
    | BookInfo Book


inApi : Api.Run Books (Api.Model Books) Msg
inApi =
    Api.runCustom identity always BooksApiMsg


init : Flags -> ( Model, Cmd Msg )
init () =
    save Blank


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( FetchBooks, _ ) ->
            let
                request =
                    { endpoint = "/books"
                    , method = HttpGet
                    , decoder = Json.field "books" (Json.list bookDecoder)
                    , headers = []
                    }
            in
            JsonApi.init request
                |> andThen Api.sendSimpleRequest
                |> map BookList
                |> mapCmd BooksApiMsg

        ( ShowBook book, _ ) ->
            save (BookInfo book)

        ( BooksApiMsg apiMsg, BookList apiModel ) ->
            apiModel
                |> inApi (Api.update apiMsg apiDefaultHandlers)
                |> map BookList

        _ ->
            save model


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view model =
    { title = ""
    , body =
        [ case model of
            Blank ->
                button
                    [ onClick FetchBooks ]
                    [ text "Fetch books" ]

            BookList { resource } ->
                case resource of
                    Available books ->
                        let
                            bookItem book =
                                li
                                    []
                                    [ text book.title
                                    , a
                                        [ href "#"
                                        , onClick (ShowBook book)
                                        ]
                                        [ text "View" ]
                                    ]
                        in
                        ul [] (List.map bookItem books)

                    Requested ->
                        text "Loading..."

                    _ ->
                        text ""

            BookInfo { id, title, author, synopsis } ->
                div
                    []
                    [ div []
                        [ h3 [] [ text title ]
                        , p [] [ text ("By: " ++ author) ]
                        , p [] [ text synopsis ]
                        ]
                    , div []
                        [ button
                            [ onClick FetchBooks ]
                            [ text "Go back" ]
                        ]
                    ]
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
