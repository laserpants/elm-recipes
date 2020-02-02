module Recipes.Api.Collection exposing (Collection, Envelope, Msg(..), RequestConfig, defaultQueryFormat, fetchPage, init, run, setLimit, update, updateCurrentPage)

import Http exposing (Expect)
import Recipes.Api as Api exposing (Resource(..), apiDefaultHandlers)
import Recipes.Helpers exposing (Bundle, Extended, runBundle)
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


setCurrent :
    Int
    -> Extended (Collection item) a
    -> ( Extended (Collection item) a, Cmd msg )
setCurrent page ( model, calls ) =
    save ( { model | current = page }, calls )


setPages :
    Int
    -> Extended (Collection item) a
    -> ( Extended (Collection item) a, Cmd msg )
setPages pages ( model, calls ) =
    save ( { model | pages = pages }, calls )


fetchPage :
    Extended (Collection item) a
    -> ( Extended (Collection item) a, Cmd (Msg item) )
fetchPage model =
    let
        ( { limit, current, query }, _ ) =
            model

        offset =
            limit * (current - 1)
    in
    model
        |> Api.xxx ApiMsg (Api.sendRequest (query offset limit) Nothing)


goToPage :
    Int
    -> Extended (Collection item) a
    -> ( Extended (Collection item) a, Cmd (Msg item) )
goToPage page ( model, calls ) =
    fetchPage ( { model | current = page }, calls )


nextPage :
    Extended (Collection item) a
    -> ( Extended (Collection item) a, Cmd (Msg item) )
nextPage =
    using (\( { current }, _ ) -> goToPage (current + 1))


prevPage :
    Extended (Collection item) a
    -> ( Extended (Collection item) a, Cmd (Msg item) )
prevPage =
    using (\( { current }, _ ) -> goToPage (max 1 (current - 1)))


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
    -> Bundle { a | api : Collection item } (Collection item) msg (Msg item)
    -> { a | api : Collection item }
    -> ( { a | api : Collection item }, Cmd msg )
run =
    runBundle
        (\model -> ( model.api, [] ))
        (\api model -> { model | api = api })


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
    -> Extended (Collection item) a
    -> ( Extended (Collection item) a, Cmd (Msg item) )
updateCurrentPage { total } model =
    let
        ( { limit }, _ ) =
            model

        pages =
            (total + limit - 1) // limit
    in
    model
        |> save
        |> andThen (setPages pages)
        |> andThen (with (Tuple.first >> .current) (setCurrent << clamp 1 pages))


setLimit :
    Int
    -> Extended (Collection item) a
    -> ( Extended (Collection item) a, Cmd msg )
setLimit limit ( model, calls ) =
    save ( { model | limit = limit }, calls )


update :
    Msg item
    -> Extended (Collection item) a
    -> ( Extended (Collection item) a, Cmd (Msg item) )
update msg =
    case msg of
        ApiMsg apiMsg ->
            Api.xxx ApiMsg (Api.update apiMsg { apiDefaultHandlers | onSuccess = updateCurrentPage })

        NextPage ->
            nextPage

        PrevPage ->
            prevPage

        GoToPage page ->
            goToPage page
