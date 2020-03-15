module Main exposing (..)

import Browser exposing (Document, document)
import Data.Book as Book exposing (Book)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import Recipes.Api as Api exposing (..)
import Recipes.Api.Json as JsonApi
import Update.Pipeline exposing (andMap, andThen, save)
import Update.Pipeline.Extended exposing (Run, runStack)


type alias Flags =
    ()


type alias BookList =
    List Book


type Field
    = Title
    | Author


type Msg
    = BookListMsg (Api.Msg BookList)
    | BookMsg (Api.Msg Book)
    | AddBook
    | RefreshList
    | Input Field String


type alias Fields =
    { bookTitle : String
    , bookAuthor : String
    }


type alias Model =
    { bookList : Api.Model BookList
    , book : Api.Model Book
    , fields : Fields
    }


insertAsBookListIn : Model -> Api.Model BookList -> ( Model, Cmd msg )
insertAsBookListIn model bookList =
    save { model | bookList = bookList }


insertAsBookIn : Model -> Api.Model Book -> ( Model, Cmd msg )
insertAsBookIn model book =
    save { model | book = book }


insertAsFieldsIn : Model -> Fields -> ( Model, Cmd msg )
insertAsFieldsIn model fields =
    save { model | fields = fields }


clearFields : Model -> ( Model, Cmd msg )
clearFields model =
    model.fields
        |> setBookTitle ""
        |> setBookAuthor ""
        |> insertAsFieldsIn model


setBookTitle : String -> Fields -> Fields
setBookTitle title fields =
    { fields | bookTitle = title }


setBookAuthor : String -> Fields -> Fields
setBookAuthor author fields =
    { fields | bookAuthor = author }


inBookListApi : Run Model (Api.Model BookList) Msg (Api.Msg BookList) a
inBookListApi =
    runStack .bookList insertAsBookListIn BookListMsg


inBookApi : Run Model (Api.Model Book) Msg (Api.Msg Book) a
inBookApi =
    runStack .book insertAsBookIn BookMsg


init : Flags -> ( Model, Cmd Msg )
init () =
    let
        bookListApi =
            JsonApi.init
                { endpoint = "/books"
                , method = HttpGet
                , decoder = Json.field "books" (Json.list Book.decoder)
                , headers = []
                }

        bookApi =
            JsonApi.init
                { endpoint = "/books"
                , method = HttpPost
                , decoder = Json.field "book" Book.decoder
                , headers = []
                }

        fields =
            { bookTitle = ""
            , bookAuthor = ""
            }
    in
    save Model
        |> andMap bookListApi
        |> andMap bookApi
        |> andMap (save fields)
        |> andThen (inBookListApi sendEmptyRequest)


handleSuccess : Book -> Model -> ( Model, Cmd Msg )
handleSuccess book =
    let
        appendBook books =
            book :: books
    in
    inBookListApi (Api.withResource appendBook)
        >> andThen clearFields


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BookListMsg apiMsg ->
            model
                |> inBookListApi (Api.update apiMsg apiDefaultHandlers)

        BookMsg apiMsg ->
            model
                |> inBookApi
                    (Api.update apiMsg
                        { apiDefaultHandlers | onSuccess = handleSuccess }
                    )

        AddBook ->
            let
                { bookTitle, bookAuthor } =
                    model.fields

                book =
                    { id = Nothing
                    , title = bookTitle
                    , author = bookAuthor
                    , synopsis = "" -- Not used in this example
                    }

                json =
                    Http.jsonBody (Book.encoder book)
            in
            model
                |> inBookApi (Api.sendRequest "" (Just json))

        RefreshList ->
            model
                |> inBookListApi Api.sendEmptyRequest

        Input Title title ->
            model.fields
                |> setBookTitle title
                |> insertAsFieldsIn model

        Input Author author ->
            model.fields
                |> setBookAuthor author
                |> insertAsFieldsIn model


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


bookListView : Api.Model BookList -> Html Msg
bookListView { resource } =
    let
        showId =
            Maybe.withDefault "-" << Maybe.map String.fromInt
    in
    case resource of
        Available books ->
            let
                row { id, title, author } =
                    tr
                        []
                        [ td [] [ text (showId id) ]
                        , td []
                            [ text title
                            ]
                        , td [] [ text author ]
                        ]
            in
            div
                []
                [ table [] (List.map row books)
                ]

        Requested ->
            text "Loading..."

        _ ->
            text ""


newBookForm : Api.Model Book -> Fields -> Html Msg
newBookForm { resource } { bookTitle, bookAuthor } =
    case resource of
        Requested ->
            text "..."

        _ ->
            let
                formItem =
                    style "padding" "0.2rem 0"
            in
            div []
                [ div
                    []
                    [ h3 [] [ text "Add a new book" ]
                    ]
                , div
                    []
                    [ label [] [ text "Title" ]
                    ]
                , div
                    [ formItem ]
                    [ input
                        [ placeholder "Book title"
                        , value bookTitle
                        , onInput (Input Title)
                        ]
                        []
                    ]
                , div
                    []
                    [ label [] [ text "Author" ]
                    ]
                , div
                    [ formItem ]
                    [ input
                        [ placeholder "Author"
                        , value bookAuthor
                        , onInput (Input Author)
                        ]
                        []
                    ]
                , div
                    [ formItem ]
                    [ button
                        [ onClick AddBook
                        , disabled (bookTitle == "" || bookAuthor == "")
                        ]
                        [ text "Save" ]
                    ]
                ]


view : Model -> Document Msg
view { bookList, book, fields } =
    { title = "Api recipe example"
    , body =
        [ div [] [ bookListView bookList ]
        , div [] [ button [ onClick RefreshList ] [ text "Refresh" ] ]
        , div [] [ hr [] [] ]
        , div [] [ newBookForm book fields ]
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
