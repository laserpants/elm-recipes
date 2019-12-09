module Update.Api exposing (..)

import Http exposing (Expect, emptyBody)
import Update.Pipeline exposing (andAddCmd, mapCmd, save, sequence, using)


withCalls : List c -> ( a, Cmd msg ) -> ( ( a, List c ), Cmd msg )
withCalls funs ( model, cmd ) =
    ( ( model, funs ), cmd )


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


setResource : Resource resource -> Model resource -> ( Model resource, Cmd (Msg resource) )
setResource resource model =
    save { model | resource = resource }


updateResourceWith : (resource -> resource) -> Model resource -> ( Model resource, Cmd (Msg resource) )
updateResourceWith updater model =
    case model.resource of
        Available available ->
            model
                |> setResource (Available (updater available))

        _ ->
            save model


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


type alias Bundle resource model msg =
    Model resource -> ( ( Model resource, List (model -> ( model, Cmd msg )) ), Cmd (Msg resource) )


runCustom :
    (model -> Model resource)
    -> (Model resource -> model -> model)
    -> (Msg resource -> msg)
    -> Bundle resource model msg
    -> model
    -> ( model, Cmd msg )
runCustom get set toMsg updater model =
    let
        ( ( api, calls ), cmd ) =
            updater (get model)
    in
    set api model
        |> sequence calls
        |> andAddCmd (Cmd.map toMsg cmd)


run :
    (Msg resource -> msg)
    -> Bundle resource { a | api : Model resource } msg
    -> { a | api : Model resource }
    -> ( { a | api : Model resource }, Cmd msg )
run =
    let
        setApi api model =
            { model | api = api }
    in
    runCustom .api setApi


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


initMap : (Msg resource -> msg) -> RequestConfig resource -> ( Model resource, Cmd msg )
initMap toMsg =
    mapCmd toMsg << init


toHeader : ( String, String ) -> Http.Header
toHeader ( a, b ) =
    Http.header a b


sendRequest :
    String
    -> Maybe Http.Body
    -> Model resource
    -> ( Model resource, Cmd (Msg resource) )
sendRequest suffix maybeBody model =
    model
        |> setResource Requested
        |> andAddCmd (model.request suffix maybeBody)


sendSimpleRequest : Model resource -> ( Model resource, Cmd (Msg resource) )
sendSimpleRequest =
    sendRequest "" Nothing


resetResource : Model resource -> ( Model resource, Cmd (Msg resource) )
resetResource =
    setResource NotRequested


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
update msg { onSuccess, onError } =
    case msg of
        Response (Ok resource) ->
            setResource (Available resource)
                >> withCalls [ onSuccess resource ]

        Response (Err error) ->
            setResource (Error error)
                >> withCalls [ onError error ]
