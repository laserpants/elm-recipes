module Main exposing (..)

import Browser exposing (Document, document)
import Data.Book as Book exposing (Book)
import Html exposing (a, button, div, h2, h3, i, li, p, table, td, text, tr, ul)
import Html.Attributes exposing (href)
import Html.Events exposing (..)
import Json.Decode as Json
import Recipes.Api as Api exposing (..)
import Recipes.Api.Json as JsonApi exposing (..)
import Recipes.Api.Json as JsonApi exposing (..)
import Update.Pipeline exposing (..)


type alias Flags =
    ()


type alias BookList =
    List Book


type Msg
    = FetchBooks
    | ShowBook Book
    | BooksApiMsg (Api.Msg BookList)


type Model
    = Blank
    | BookList (Api.Model BookList)
    | BookInfo Book



inBookList =
    Debug.todo ""

--inBookList
--    : Bundle (Api.Model BookList) (Api.Model BookList) Msg (Api.Msg BookList)
--    -> Api.Model BookList
--    -> ( Model, Cmd Msg )
--inBookList bundle model =
--    bundle ( model, [] )
--        |> mapCmd BooksApiMsg
--        |> sequenceCalls
--        |> map BookList


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
            Debug.todo ""
--            JsonApi.initAndRequest request
--                |> mapCmd BooksApiMsg
--                |> map BookList

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
                            showId =
                                Maybe.withDefault "-" << Maybe.map String.fromInt

                            bookItem ({ id, title, author } as book) =
                                tr
                                    []
                                    [ td [] [ text (showId id) ]
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
