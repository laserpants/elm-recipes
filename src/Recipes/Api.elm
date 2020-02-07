module Recipes.Api exposing (..)

import Http exposing (Expect, emptyBody)
import Update.Pipeline exposing (andAddCmd, save, using)
import Update.Pipeline.Extended exposing (Extended, Run, andCall, lift, runStack)


type Msg resource
    = Response (Result Http.Error resource)


type Resource resource
    = NotRequested
    | Requested
    | Error Http.Error
    | Available resource


type alias Request resource =
    String -> Maybe Http.Body -> Cmd (Msg resource)


type alias Model resource =
    { resource : Resource resource
    , request : Request resource
    }


setResource :
    Resource resource
    -> Model resource
    -> ( Model resource, Cmd (Msg resource) )
setResource resource model =
    save { model | resource = resource }


resetResource :
    Model resource
    -> ( Model resource, Cmd (Msg resource) )
resetResource =
    setResource NotRequested


type HttpMethod
    = HttpGet
    | HttpPost
    | HttpPut


type alias RequestConfig resource =
    { endpoint : String
    , method : HttpMethod
    , expect : Expect (Msg resource)
    , headers : List ( String, String )
    }


init : RequestConfig resource -> ( Model resource, Cmd msg )
init { endpoint, method, expect, headers } =
    let
        methodStr =
            case method of
                HttpGet ->
                    "GET"

                HttpPost ->
                    "POST"

                HttpPut ->
                    "PUT"

        request suffix body =
            Http.request
                { method = methodStr
                , headers = List.map toHeader headers
                , url = endpoint ++ suffix
                , expect = expect
                , body = Maybe.withDefault emptyBody body
                , timeout = Nothing
                , tracker = Nothing
                }
    in
    save { resource = NotRequested, request = request }


toHeader : ( String, String ) -> Http.Header
toHeader ( a, b ) =
    Http.header a b


apiDefaultHandlers :
    { onSuccess : resource -> a -> ( a, Cmd msg )
    , onError : Http.Error -> a1 -> ( a1, Cmd msg1 )
    }
apiDefaultHandlers =
    { onSuccess = always save
    , onError = always save
    }


sendRequest :
    String
    -> Maybe Http.Body
    -> Extended (Model resource) a
    -> ( Extended (Model resource) a, Cmd (Msg resource) )
sendRequest suffix maybeBody model =
    let
        ( { request }, _ ) =
            model
    in
    model
        |> lift (setResource Requested)
        |> andAddCmd (request suffix maybeBody)


sendEmptyRequest :
    Extended (Model resource) a
    -> ( Extended (Model resource) a, Cmd (Msg resource) )
sendEmptyRequest =
    sendRequest "" Nothing


withResource :
    (resource -> resource)
    -> Extended (Model resource) a
    -> ( Extended (Model resource) a, Cmd (Msg resource) )
withResource fun =
    using
        (\( { resource }, _ ) ->
            case resource of
                Available item ->
                    lift (setResource (Available (fun item)))

                _ ->
                    save
        )


update :
    Msg resource
    ->
        { onSuccess : resource -> a
        , onError : Http.Error -> a
        }
    -> Extended (Model resource) a
    -> ( Extended (Model resource) a, Cmd (Msg resource) )
update msg { onSuccess, onError } model =
    case msg of
        Response (Ok resource) ->
            model
                |> lift (setResource (Available resource))
                |> andCall (onSuccess resource)

        Response (Err error) ->
            model
                |> lift (setResource (Error error))
                |> andCall (onError error)


type alias HasApi resource a =
    { a | api : Model resource }


insertAsApiIn :
    HasApi resource a
    -> Model resource
    -> ( HasApi resource a, Cmd msg )
insertAsApiIn model api =
    save { model | api = api }


run :
    (Msg resource -> msg)
    -> Run (HasApi resource a) (Model resource) msg (Msg resource) c
run =
    runStack .api insertAsApiIn


runUpdate :
    (Msg resource -> msg)
    -> Msg resource
    ->
        { onSuccess : resource -> HasApi resource a -> ( HasApi resource a, Cmd msg )
        , onError : Http.Error -> HasApi resource a -> ( HasApi resource a, Cmd msg )
        }
    -> HasApi resource a
    -> ( HasApi resource a, Cmd msg )
runUpdate toMsg msg handlers =
    update msg handlers
        |> run toMsg
