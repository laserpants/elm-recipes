module Main exposing (..)

import Browser exposing (Document, document)
import Data.Book as Book exposing (Book)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Recipes.Api as Api exposing (..)
import Recipes.Api.Json as JsonApi exposing (..)
import Recipes.Helpers exposing (..)
import Update.Pipeline exposing (..)
import Url exposing (Url)


type alias Flags =
    ()


type alias BookList =
    List Book


type Msg
    = BookListMsg (Api.Msg BookList)
    | BookItemMsg (Api.Msg Book)


type alias Model =
    { bookList : Api.Model BookList
    , bookItem : Api.Model Book
    }


inBookListApi :
    Bundle (Api.Model BookList) (Api.Msg BookList) Model Msg
    -> Model
    -> ( Model, Cmd Msg )
inBookListApi =
    runBundle .bookList (\list model -> { model | bookList = list }) BookListMsg


inBookItemApi :
    Bundle (Api.Model Book) (Api.Msg Book) Model Msg
    -> Model
    -> ( Model, Cmd Msg )
inBookItemApi =
    runBundle .bookItem (\item model -> { model | bookItem = item }) BookItemMsg


init : Flags -> ( Model, Cmd Msg )
init () =
    let
        listApi =
            JsonApi.init
                { endpoint = "/books"
                , method = HttpGet
                , decoder = Json.field "books" (Json.list Book.decoder)
                , headers = []
                }

        itemApi =
            JsonApi.init
                { endpoint = "/books"
                , method = HttpPost
                , decoder = Json.field "book" Book.decoder
                , headers = []
                }
    in
    save Model
        |> andMap (mapCmd BookListMsg listApi)
        |> andMap (mapCmd BookItemMsg itemApi)
        |> andThen (inBookListApi sendSimpleRequest)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BookListMsg apiMsg ->
            model
                |> inBookListApi (Api.update apiMsg apiDefaultHandlers)

        BookItemMsg apiMsg ->
            model
                |> inBookItemApi (Api.update apiMsg apiDefaultHandlers)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view { bookList, bookItem } =
    let
        { resource } =
            bookList
    in
    { title = ""
    , body =
        [ case resource of
            Available books ->
                let
                    row ({ id, title, author } as book) =
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
