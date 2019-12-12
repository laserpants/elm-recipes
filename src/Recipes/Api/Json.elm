module Recipes.Api.Json exposing (JsonRequestConfig, init, initAndRequest, sendJson)

import Http
import Json.Decode as Json
import Recipes.Api as Api exposing (HttpMethod, Model, Msg(..))


sendJson :
    String
    -> Json.Value
    -> Model resource
    -> ( ( Model resource, List a ), Cmd (Msg resource) )
sendJson suffix =
    Http.jsonBody >> Just >> Api.sendRequest suffix


type alias JsonRequestConfig resource =
    { endpoint : String
    , method : HttpMethod
    , decoder : Json.Decoder resource
    , headers : List ( String, String )
    }


toRequest : JsonRequestConfig resource -> Api.RequestConfig resource
toRequest { endpoint, method, decoder, headers } =
    { endpoint = endpoint
    , method = method
    , expect = Http.expectJson Response decoder
    , headers = headers
    }


init : JsonRequestConfig resource -> ( Model resource, Cmd (Msg resource) )
init =
    Api.init << toRequest


initAndRequest : JsonRequestConfig resource -> ( Model resource, Cmd (Msg resource) )
initAndRequest =
    Api.initAndRequest << toRequest
