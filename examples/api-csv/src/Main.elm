module Main exposing (..)

import Browser exposing (Document, document)
import Csv
import Csv.Decode
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (Expect)
import Recipes.Api as Api exposing (..)
import Update.Pipeline exposing (andMap, mapCmd, save)


type alias Book =
    { id : Maybe Int
    , title : String
    , author : String
    , synopsis : String
    }



--bookDecoder : Csv.Decode.Decoder (Book -> Book) Book


bookDecoder =
    Csv.Decode.map Book
        (Csv.Decode.next (Csv.Decode.maybe (Result.fromMaybe "Not an int" << String.toInt))
            |> Csv.Decode.andMap (Csv.Decode.next Ok)
            |> Csv.Decode.andMap (Csv.Decode.next Ok)
            |> Csv.Decode.andMap (Csv.Decode.next Ok)
        )


type Msg
    = ApiMsg (Api.Msg Book)
    | FetchBook
    | ResetBook


type alias Model =
    { api : Api.Model Book
    }



--expectCsv : (Result Http.Error (List Book) -> msg) -> Csv.Decode.Decoder (Book -> Book) Book -> Expect msg


expectCsv toMsg decoder =
    Http.expectStringResponse toMsg <|
        \response ->
            case response of
                Http.GoodStatus_ _ body ->
                    case Csv.parse body |> Csv.Decode.decodeCsv bookDecoder of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err (Http.BadBody "Unexpected CSV")

                Http.BadUrl_ url ->
                    Err (Http.BadUrl url)

                Http.Timeout_ ->
                    Err Http.Timeout

                Http.NetworkError_ ->
                    Err Http.NetworkError

                Http.BadStatus_ metadata _ ->
                    Err (Http.BadStatus metadata.statusCode)


init : () -> ( Model, Cmd Msg )
init () =
    let
        api =
            Api.init
                { endpoint = "/books/1"
                , method = HttpGet
                , expect = expectCsv (Debug.todo "") bookDecoder
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
