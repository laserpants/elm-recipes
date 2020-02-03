module Recipes.Api.Json exposing (..)

import Http
import Json.Decode as Json
import Recipes.Api as Api exposing (HttpMethod, Model, Msg(..))
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


init : JsonRequestConfig resource -> ( Model resource, Cmd (Msg resource) )
init =
    Api.init << requestConfig


--initAndRequest : JsonRequestConfig resource -> ( Model resource, Cmd (Msg resource) )
--initAndRequest =
--    Api.initAndRequest << requestConfig
