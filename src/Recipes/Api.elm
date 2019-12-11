module Recipes.Api exposing (..)

import Http exposing (Expect, emptyBody)
import Recipes.Helpers as Helpers exposing (..)
import Update.Pipeline exposing (andAddCmd, andThen, mapCmd, save, sequence, using)


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
    -> ( Model resource, List a )
    -> ( ( Model resource, List a ), Cmd (Msg resource) )
setResource resource ( model, calls ) =
    save ( { model | resource = resource }, calls )


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


run :
    (Msg resource -> msg)
    -> Bundle (Model resource) (Msg resource) { a | api : Model resource } msg
    -> { a | api : Model resource }
    -> ( { a | api : Model resource }, Cmd msg )
run =
    let
        setApi api model =
            { model | api = api }
    in
    runBundle .api setApi


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


initRequest :
    RequestConfig resource
    -> ( Model resource, Cmd (Msg resource) )
initRequest =
    init
        >> andThen sendSimpleRequest
        >> sequenceCalls


toHeader : ( String, String ) -> Http.Header
toHeader ( a, b ) =
    Http.header a b


sendRequest :
    String
    -> Maybe Http.Body
    -> Model resource
    -> ( ( Model resource, List a ), Cmd (Msg resource) )
sendRequest suffix maybeBody model =
    ( model, [] )
        |> setResource Requested
        |> andAddCmd (model.request suffix maybeBody)


sendSimpleRequest : Model resource -> ( ( Model resource, List a ), Cmd (Msg resource) )
sendSimpleRequest =
    sendRequest "" Nothing


resetResource : Model resource -> ( ( Model resource, List a ), Cmd (Msg resource) )
resetResource model =
    ( model, [] )
        |> setResource NotRequested


apiDefaultHandlers :
    { onError : Http.Error -> a1 -> ( a1, Cmd msg1 )
    , onSuccess : resource -> a -> ( a, Cmd msg )
    }
apiDefaultHandlers =
    { onSuccess = always save
    , onError = always save
    }


update :
    Msg resource
    -> { onSuccess : resource -> a, onError : Http.Error -> a }
    -> Model resource
    -> ( ( Model resource, List a ), Cmd (Msg resource) )
update msg { onSuccess, onError } model =
    case msg of
        Response (Ok resource) ->
            ( model, [] )
                |> setResource (Available resource)
                |> andCall (onSuccess resource)

        Response (Err error) ->
            ( model, [] )
                |> setResource (Error error)
                |> andCall (onError error)