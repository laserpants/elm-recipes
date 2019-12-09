module Main exposing (..)

import Browser exposing (Document, document)
import Data.Book as Book exposing (Book)
import Html exposing (a, button, div, h2, h3, i, li, p, table, td, text, tr, ul)
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


type Model
    = Blank
    | BookList (Api.Model Books)
    | BookInfo Book


inBookList :
    Api.Bundle Books (Api.Model Books) Msg
    -> Api.Model Books
    -> ( Model, Cmd Msg )
inBookList fun =
    Api.runCustom identity always BooksApiMsg fun
        >> map BookList


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
                    , decoder = Json.field "books" (Json.list Book.decoder)
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
                |> inBookList (Api.update apiMsg apiDefaultHandlers)

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
                            bookItem ({ id, title, author } as book) =
                                tr
                                    []
                                    [ td [] [ text (String.fromInt id) ]
                                    , td []
                                        [ a
                                            [ href "#"
                                            , onClick (ShowBook book)
                                            ]
                                            [ text title ]
                                        ]
                                    , td [] [ text author ]
                                    ]
                        in
                        table [] (List.map bookItem books)

                    Requested ->
                        text "Loading..."

                    _ ->
                        text ""

            BookInfo { id, title, author, synopsis } ->
                div
                    []
                    [ div []
                        [ h3 [] [ text title ]
                        , p []
                            [ text "By: "
                            , i [] [ text author ]
                            ]
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
