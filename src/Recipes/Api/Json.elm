module Recipes.Api.Json exposing (JsonRequestConfig, init, makeRequest, sendJson)

import Http
import Json.Decode as Json
import Recipes.Api as Api exposing (HttpMethod, Model, Msg(..))
import Update.Pipeline exposing (mapCmd)
import Update.Pipeline.Extended exposing (Extended)


sendJson :
    String
    -> Json.Value
    -> Extended (Model resource) a
    -> ( Extended (Model resource) a, Cmd (Msg resource) )
sendJson suffix =
    Http.jsonBody >> Just >> Api.sendRequest suffix


type alias JsonRequestConfig resource =
    { endpoint : String
    , method : HttpMethod
    , decoder : Json.Decoder resource
    , headers : List ( String, String )
    }


requestConfig : JsonRequestConfig resource -> Api.RequestConfig resource
requestConfig { endpoint, method, decoder, headers } =
    { endpoint = endpoint
    , method = method
    , expect = Http.expectJson Response decoder
    , headers = headers
    }


init : JsonRequestConfig resource -> ( Model resource, Cmd msg )
init =
    Api.init << requestConfig


makeRequest : JsonRequestConfig resource -> ( Model resource, Cmd (Msg resource) )
makeRequest =
    Api.makeRequest << requestConfig
