module Update.Api.Json exposing (..)

import Http
import Json.Decode as Json
import Update.Api as Api exposing (HttpMethod, Model, Msg(..))
import Update.Pipeline exposing (mapCmd)


sendJson :
    String
    -> Json.Value
    -> Model resource
    -> ( Model resource, Cmd (Msg resource) )
sendJson suffix =
    Http.jsonBody >> Just >> Api.sendRequest suffix


type alias JsonRequestConfig resource =
    { endpoint : String
    , method : HttpMethod
    , decoder : Json.Decoder resource
    , headers : List ( String, String )
    }


init : JsonRequestConfig resource -> ( Model resource, Cmd (Msg resource) )
init { endpoint, method, decoder, headers } =
    Api.init
        { endpoint = endpoint
        , method = method
        , expect = Http.expectJson Response decoder
        , headers = headers
        }


initMap : (Msg resource -> msg) -> JsonRequestConfig resource -> ( Model resource, Cmd msg )
initMap toMsg =
    mapCmd toMsg << init
