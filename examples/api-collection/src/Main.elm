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
import Update.Pipeline exposing (..)
import Update.Pipeline.Extended exposing (..)


type alias Flags =
    ()


type Msg
    = BookCollectionMsg (Api.Msg Book)
    | GotoPrev
    | GotoNext


type alias Model =
    { api : Api.Collection Book
    }


insertAsApiIn : Model -> Api.Collection Book -> ( Model, Cmd msg )
insertAsApiIn model api =
    save { model | api = api }


inApi : Run Model (Api.Collection Book) Msg (Api.Msg Book) a
inApi =
    runStack .api insertAsApiIn BookCollectionMsg


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

        GotoPrev ->
            model
                |> inApi Api.prevPage

        GotoNext ->
            model
                |> inApi Api.nextPage


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view { api } =
    let
        { pages, current } =
            api

        prevButton =
            if current > 1 then
                [ a [ href "#", onClick GotoPrev ] [ text "Previous page" ]
                , text " | "
                ]

            else
                []

        nextButton =
            if current < pages then
                [ text " | "
                , a [ href "#", onClick GotoNext ] [ text "Next page" ]
                ]

            else
                []
    in
    { title = ""
    , body =
        [ case api.api.resource of
            Available books ->
                let
                    showId =
                        Maybe.withDefault "-" << Maybe.map String.fromInt

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
                div []
                    [ div
                        []
                        [ table [] (List.map row books.page)
                        ]
                    , div
                        []
                        (prevButton
                            ++ [ text ("Page " ++ String.fromInt current ++ " (" ++ String.fromInt pages ++ ")") ]
                            ++ nextButton
                        )
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
