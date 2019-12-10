module Recipes.Api.Collection exposing (..)

import Http exposing (Expect)
import Recipes.Api as Api exposing (Resource(..), apiDefaultHandlers)
import Update.Pipeline exposing (andMap, andThen, mapCmd, save, using, with)


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


insertAsApiIn :
    Collection item
    -> Api.Model (Envelope item)
    -> ( Collection item, Cmd msg )
insertAsApiIn state api =
    save { state | api = api }


inApi =
    Debug.todo ""


setCurrent : Int -> Collection item -> ( Collection item, Cmd msg )
setCurrent page state =
    save { state | current = page }


setPages : Int -> Collection item -> ( Collection item, Cmd msg )
setPages pages state =
    save { state | pages = pages }


setLimit : Int -> Collection item -> ( Collection item, Cmd msg )
setLimit limit state =
    save { state | limit = limit }


fetchPage : Collection item -> ( Collection item, Cmd (Msg item) )
fetchPage state =
    let
        { limit, current, query } =
            state

        offset =
            limit * (current - 1)
    in
    state
        |> inApi (Api.sendRequest (query offset limit) Nothing)


goToPage : Int -> Collection item -> ( Collection item, Cmd (Msg item) )
goToPage page =
    setCurrent page
        >> andThen fetchPage


nextPage : Collection item -> ( Collection item, Cmd (Msg item) )
nextPage =
    using (\{ current } -> goToPage (current + 1))


prevPage : Collection item -> ( Collection item, Cmd (Msg item) )
prevPage =
    using (\{ current } -> goToPage (max 1 (current - 1)))


type alias RequestConfig item =
    { limit : Int
    , endpoint : String
    , expect : Expect (Api.Msg (Envelope item))
    , headers : List ( String, String )
    , queryString : Int -> Int -> String
    }


defaultQuery : Int -> Int -> String
defaultQuery offset limit =
    "?offset=" ++ String.fromInt offset ++ "&limit=" ++ String.fromInt limit


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
        pages =
            (total + model.limit - 1) // model.limit
    in
    model
        |> setPages pages
        |> andThen (with .current (setCurrent << clamp 1 pages))


update :
    Msg item
    -> Collection item
    -> ( Collection item, Cmd (Msg item) )
update msg =
    case msg of
        ApiMsg apiMsg ->
            inApi (Api.update apiMsg { apiDefaultHandlers | onSuccess = updateCurrentPage })

        NextPage ->
            nextPage

        PrevPage ->
            prevPage

        GoToPage page ->
            goToPage page
