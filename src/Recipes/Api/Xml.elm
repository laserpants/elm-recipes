module Recipes.Api.Xml exposing (XmlRequestConfig, init, initAndRequest, sendXml)

import Http
import Http.Xml as Http
import Recipes.Api as Api exposing (HttpMethod, Model, Msg(..))
import Update.Pipeline.Extended exposing (Extended)
import Xml.Decode as Xml


sendXml :
    String
    -> String
    -> Extended (Model resource) a
    -> ( Extended (Model resource) a, Cmd (Msg resource) )
sendXml suffix =
    Http.xmlBody >> Just >> Api.sendRequest suffix


type alias XmlRequestConfig resource =
    { endpoint : String
    , method : HttpMethod
    , decoder : Xml.Decoder resource
    , headers : List ( String, String )
    }


requestConfig : XmlRequestConfig resource -> Api.RequestConfig resource
requestConfig { endpoint, method, decoder, headers } =
    { endpoint = endpoint
    , method = method
    , expect = Http.expectXml Response decoder
    , headers = headers
    }


init : XmlRequestConfig resource -> ( Model resource, Cmd msg )
init =
    Api.init << requestConfig


initAndRequest : XmlRequestConfig resource -> ( Model resource, Cmd (Msg resource) )
initAndRequest =
    Api.initAndRequest << requestConfig
