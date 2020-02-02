module Recipes.Api exposing (HttpMethod(..), Model, Msg(..), RequestConfig, Resource(..), apiDefaultHandlers, init, initAndRequest, resetResource, run, sendEmptyRequest, sendRequest, update, withResource, xxx)

import Http exposing (Expect, emptyBody)
import Recipes.Helpers exposing (Bundle, Extended, andCall, runBundle, sequenceCalls, mapExtended, lift)
import Update.Pipeline exposing (andAddCmd, andThen, save, using, map)


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


type HttpMethod
    = HttpGet
    | HttpPost
    | HttpPut


type alias RequestConfig resource =
    { endpoint : String
    , method : HttpMethod , expect : Expect (Msg resource)
    , headers : List ( String, String )
    }


run :
    (Msg resource -> msg)
    -> Bundle { a | api : Model resource } (Model resource) msg (Msg resource)
    -> { a | api : Model resource }
    -> ( { a | api : Model resource }, Cmd msg )
run =
    runBundle
        (\model -> ( model.api, [] ))
        (\api model -> { model | api = api })


xxx :
    (Msg resource -> msg)
    -> Bundle ( { a | api : Model resource }, List c ) (Model resource) msg (Msg resource)
    -> ( { a | api : Model resource }, List c )
    -> ( ( { a | api : Model resource }, List c ), Cmd msg )
xxx =
    runBundle
        (\( model, _ ) -> ( model.api, [] ))
        (\api ( model, _ ) -> ( { model | api = api }, [] ))


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


initAndRequest : RequestConfig resource -> ( Model resource, Cmd (Msg resource) )
initAndRequest req =
    init req
        |> andThen (\model -> sendEmptyRequest ( model, [] ))
        |> sequenceCalls


toHeader : ( String, String ) -> Http.Header
toHeader ( a, b ) =
    Http.header a b


apiDefaultHandlers :
    { onError : Http.Error -> a1 -> ( a1, Cmd msg1 )
    , onSuccess : resource -> a -> ( a, Cmd msg )
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


resetResource :
    Extended (Model resource) a
    -> ( Extended (Model resource) a, Cmd (Msg resource) )
resetResource =
    lift (setResource NotRequested)


withResource :
    (resource -> resource)
    -> Extended (Model resource) a
    -> ( Extended (Model resource) a, Cmd (Msg resource) )
withResource fun =
    using
        (\( { resource }, _ ) ->
            case resource of
                Available res ->
                    lift (setResource (Available (fun res)))

                _ ->
                    save
        )


update :
    Msg resource
    -> { onSuccess : resource -> a, onError : Http.Error -> a }
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
