module Main exposing (..)

import Browser exposing (Document, document)
import Data.Book as Book exposing (Book)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Recipes.Api as Api exposing (..)
import Recipes.Api.Json as JsonApi
import Update.Pipeline exposing (save, andThen, andMap, mapCmd)
import Update.Pipeline.Extended exposing (runStack)


type alias Flags =
    ()


type alias BookList =
    List Book


type Msg
    = BookListMsg (Api.Msg BookList)
    | BookMsg (Api.Msg Book)


type alias Model =
    { bookList : Api.Model BookList
    , book : Api.Model Book
    }


setBookList : Model -> Api.Model BookList -> ( Model, Cmd msg )
setBookList model bookList = 
    save { model | bookList = bookList }


setBook : Model -> Api.Model Book -> ( Model, Cmd msg )
setBook model book = 
    save { model | book = book }


inBookListApi : Run Model BookList Msg a
inBookListApi =
    runStack .bookList setBookList BookListMsg


inBookApi : Run Model Book Msg a
inBookApi =
    runStack .book setBook BookMsg


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
    in
    save Model
        |> andMap (mapCmd BookListMsg bookListApi)
        |> andMap (mapCmd BookMsg bookApi)
        |> andThen (inBookListApi sendEmptyRequest)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BookListMsg apiMsg ->
            model
                |> inBookListApi (Api.update apiMsg apiDefaultHandlers)

        BookMsg apiMsg ->
            model
                |> inBookApi (Api.update apiMsg apiDefaultHandlers)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view { bookList, book } =
    let
        { resource } =
            bookList
    in
    { title = "Api recipe example"
    , body =
        [ case resource of
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
                    [ table [] (List.map row books)
                    , div [] [ hr [] [] ]
                    , div [] [ input [] [] ]
                    , div [] [ input [] [] ]
                    ]

            Requested ->
                text "Loading..."

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
