module Recipes.Api.Collection exposing (Collection, Envelope, Msg(..), RequestConfig, defaultQueryFormat, fetchPage, init, run, setLimit, update, updateCurrentPage)

import Http exposing (Expect)
import Recipes.Api as Api exposing (Resource(..), apiDefaultHandlers)
import Recipes.Helpers exposing (Bundle, lift, runBundle, saveLifted, sequenceCalls)
import Update.Pipeline exposing (andMap, andThen, save, using, with)


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


setCurrent : Int -> ( Collection item, List a ) -> ( ( Collection item, List a ), Cmd msg )
setCurrent page ( model, calls ) =
    save ( { model | current = page }, calls )


setPages : Int -> ( Collection item, List a ) -> ( ( Collection item, List a ), Cmd msg )
setPages pages ( model, calls ) =
    save ( { model | pages = pages }, calls )


fetchPage : Collection item -> ( ( Collection item, List a ), Cmd (Msg item) )
fetchPage model =
    let
        { limit, current, query } =
            model

        offset =
            limit * (current - 1)
    in
    model
        |> Api.run ApiMsg (Api.sendRequest (query offset limit) Nothing)
        |> lift


goToPage : Int -> Collection item -> ( ( Collection item, List a ), Cmd (Msg item) )
goToPage page model =
    fetchPage { model | current = page }


nextPage : Collection item -> ( ( Collection item, List a ), Cmd (Msg item) )
nextPage =
    using (\{ current } -> goToPage (current + 1))


prevPage : Collection item -> ( ( Collection item, List a ), Cmd (Msg item) )
prevPage =
    using (\{ current } -> goToPage (max 1 (current - 1)))


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
    model
        |> saveLifted
        |> andThen (setPages pages)
        |> andThen (with (.current << Tuple.first) (setCurrent << clamp 1 pages))
        |> sequenceCalls


setLimit : Int -> Collection item -> ( ( Collection item, List a ), Cmd msg )
setLimit limit model =
    saveLifted { model | limit = limit }


update :
    Msg item
    -> Collection item
    -> ( ( Collection item, List a ), Cmd (Msg item) )
update msg =
    case msg of
        ApiMsg apiMsg ->
            Api.run ApiMsg (Api.update apiMsg { apiDefaultHandlers | onSuccess = updateCurrentPage })
                >> lift

        NextPage ->
            nextPage

        PrevPage ->
            prevPage

        GoToPage page ->
            goToPage page
