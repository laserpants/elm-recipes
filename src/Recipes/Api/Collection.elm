module Recipes.Api.Collection exposing (Collection, Envelope, Msg(..), RequestConfig, defaultQueryFormat, inApi, init, run, sendRequest, sendSimpleRequest, setLimit, update, updateCurrentPage)

import Http exposing (Expect)
import Recipes.Api as Api exposing (Resource(..), apiDefaultHandlers)
import Recipes.Helpers exposing (Bundle, lift, runBundle, sequenceCalls)
import Update.Pipeline exposing (andMap, andThen, save, with)


type alias Envelope item =
    { page : List item
    , total : Int
    }


type Msg item
    = ApiMsg (Api.Msg (Envelope item))
    | NextPage
    | PrevPage
    | GoToPage Int


type alias Collection item =
    { api : Api.Model (Envelope item)
    , current : Int
    , pages : Int
    , limit : Int
    , query : Int -> Int -> String
    }


inApi :
    Bundle (Api.Model (Envelope item)) (Api.Msg (Envelope item)) (Collection item) (Msg item)
    -> Collection item
    -> ( Collection item, Cmd (Msg item) )
inApi =
    Api.run ApiMsg


setCurrent : Int -> ( Collection item, List a ) -> ( ( Collection item, List a ), Cmd msg )
setCurrent page ( model, calls ) =
    save ( { model | current = page }, calls )


setPages : Int -> ( Collection item, List a ) -> ( ( Collection item, List a ), Cmd msg )
setPages pages ( model, calls ) =
    save ( { model | pages = pages }, calls )


fetchPage : ( Collection item, List a ) -> ( ( Collection item, List a ), Cmd (Msg item) )
fetchPage ( model, _ ) =
    let
        { limit, current, query } =
            model

        offset =
            limit * (current - 1)
    in
    model
        |> inApi (Api.sendRequest (query offset limit) Nothing)
        |> lift


goToPage : Int -> ( Collection item, List a ) -> ( ( Collection item, List a ), Cmd (Msg item) )
goToPage page =
    setCurrent page
        >> andThen fetchPage


nextPage : ( Collection item, List a ) -> ( ( Collection item, List a ), Cmd (Msg item) )
nextPage ( model, calls ) =
    ( model, calls )
        |> goToPage (model.current + 1)


prevPage : ( Collection item, List a ) -> ( ( Collection item, List a ), Cmd (Msg item) )
prevPage ( model, calls ) =
    ( model, calls )
        |> goToPage (max 1 (model.current - 1))


type alias RequestConfig item =
    { limit : Int
    , endpoint : String
    , expect : Expect (Api.Msg (Envelope item))
    , headers : List ( String, String )
    , queryString : Int -> Int -> String
    }


defaultQueryFormat : Int -> Int -> String
defaultQueryFormat offset limit =
    "?offset=" ++ String.fromInt offset ++ "&limit=" ++ String.fromInt limit


run :
    (Msg item -> msg)
    -> Bundle (Collection item) (Msg item) { a | api : Collection item } msg
    -> { a | api : Collection item }
    -> ( { a | api : Collection item }, Cmd msg )
run =
    let
        setApi api model =
            { model | api = api }
    in
    runBundle .api setApi


init : RequestConfig item -> ( Collection item, Cmd (Msg item) )
init { limit, endpoint, expect, headers, queryString } =
    let
        api =
            Api.init
                { endpoint = endpoint
                , method = Api.HttpGet
                , expect = expect
                , headers = headers
                }
    in
    save Collection
        |> andMap api
        |> andMap (save 1)
        |> andMap (save 0)
        |> andMap (save limit)
        |> andMap (save queryString)


updateCurrentPage :
    Envelope item
    -> Collection item
    -> ( Collection item, Cmd (Msg item) )
updateCurrentPage { total } model =
    let
        { limit } =
            model

        pages =
            (total + limit - 1) // limit
    in
    ( model, [] )
        |> setPages pages
        |> andThen (with (.current << Tuple.first) (setCurrent << clamp 1 pages))
        |> sequenceCalls


sendRequest :
    String
    -> Maybe Http.Body
    -> Collection item
    -> ( ( Collection item, List a ), Cmd (Msg item) )
sendRequest suffix maybeBody =
    lift << inApi (Api.sendRequest suffix maybeBody)


sendSimpleRequest : Collection item -> ( ( Collection item, List a ), Cmd (Msg item) )
sendSimpleRequest =
    lift << inApi Api.sendSimpleRequest


setLimit : Int -> Collection item -> ( ( Collection item, List a ), Cmd msg )
setLimit limit model =
    save ( { model | limit = limit }, [] )


update :
    Msg item
    -> Collection item
    -> ( ( Collection item, List a ), Cmd (Msg item) )
update msg model =
    case msg of
        ApiMsg apiMsg ->
            model
                |> inApi (Api.update apiMsg { apiDefaultHandlers | onSuccess = updateCurrentPage })
                |> lift

        NextPage ->
            ( model, [] )
                |> nextPage

        PrevPage ->
            ( model, [] )
                |> prevPage

        GoToPage page ->
            ( model, [] )
                |> goToPage page
