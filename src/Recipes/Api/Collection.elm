module Recipes.Api.Collection exposing (..)

import Http exposing (Expect)
import Recipes.Api as Api exposing (Resource(..), apiDefaultHandlers)
import Update.Pipeline exposing (andMap, andThen, save, using, with)
import Update.Pipeline.Extended exposing (Extended, Run, andLift, lift, runStack, runStackE)
import Url.Builder as Builder


type alias Envelope item =
    { page : List item
    , total : Int
    }


type Msg item
    = ApiMsg (Api.Msg (Envelope item))
    | NextPage
    | PrevPage
    | GotoPage Int


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
    -> ( Collection item, Cmd (Msg item) )
insertAsApiIn model api =
    save { model | api = api }


setCurrent :
    Int
    -> Collection item
    -> ( Collection item, Cmd msg )
setCurrent page model =
    save { model | current = page }


setPages :
    Int
    -> Collection item
    -> ( Collection item, Cmd msg )
setPages pages model =
    save { model | pages = pages }


type alias RequestConfig item =
    { limit : Int
    , endpoint : String
    , expect : Expect (Api.Msg (Envelope item))
    , headers : List ( String, String )
    , queryString : Int -> Int -> String
    }


defaultQueryFormat : Int -> Int -> String
defaultQueryFormat offset limit =
    Builder.relative []
        [ Builder.int "offset" offset
        , Builder.int "limit" limit
        ]


inApi : Run (Extended (Collection item) e) (Api.Model (Envelope item)) (Msg item) (Api.Msg (Envelope item)) a
inApi =
    runStackE .api insertAsApiIn ApiMsg


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


fetchPage :
    Extended (Collection item) a
    -> ( Extended (Collection item) a, Cmd (Msg item) )
fetchPage (( { limit, current, query }, _ ) as model) =
    let
        offset =
            limit * (current - 1)
    in
    model
        |> inApi (Api.sendRequest (query offset limit) Nothing)


goToPage :
    Int
    -> Extended (Collection item) a
    -> ( Extended (Collection item) a, Cmd (Msg item) )
goToPage page (( { pages }, _ ) as model) =
    model
        |> lift (setCurrent (clamp 1 pages page))
        |> andThen fetchPage


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


updateCurrentPage :
    Envelope item
    -> Extended (Collection item) a
    -> ( Extended (Collection item) a, Cmd (Msg item) )
updateCurrentPage { total } (( { limit }, _ ) as model) =
    let
        pages =
            (total + limit - 1) // limit
    in
    model
        |> save
        |> andLift (setPages pages)
        |> andThen
            (with (Tuple.first >> .current)
                (lift << setCurrent << clamp 1 pages)
            )


update :
    Msg item
    -> Extended (Collection item) a
    -> ( Extended (Collection item) a, Cmd (Msg item) )
update msg =
    case msg of
        ApiMsg apiMsg ->
            inApi (Api.update apiMsg { apiDefaultHandlers | onSuccess = updateCurrentPage })

        NextPage ->
            nextPage

        PrevPage ->
            prevPage

        GotoPage page ->
            goToPage page


type alias HasCollection item a =
    { a | api : Collection item }


run : (msg1 -> msg) -> Run (HasCollection item a) (Collection item) msg msg1 b
run =
    runStack .api (\model api -> save { model | api = api })


runUpdate :
    (Msg item -> msg)
    -> Msg item
    -> HasCollection item a
    -> ( HasCollection item a, Cmd msg )
runUpdate toMsg msg =
    update msg
        |> run toMsg
