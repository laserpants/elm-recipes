module Recipes.Api.Collection.Json exposing (..)

import Http
import Json.Decode as Json
import Recipes.Api exposing (Msg(..))
import Recipes.Api.Collection as Collection exposing (Collection, Envelope, Msg)


type alias JsonRequestConfig item =
    { limit : Int
    , endpoint : String
    , decoder : Json.Decoder (Envelope item)
    , headers : List ( String, String )
    , queryString : Int -> Int -> String
    }


envelopeDecoder : String -> Json.Decoder item -> Json.Decoder (Envelope item)
envelopeDecoder key itemDecoder =
    Json.map2 Envelope
        (Json.field key (Json.list itemDecoder))
        (Json.field "total" Json.int)


init : JsonRequestConfig item -> ( Collection item, Cmd (Msg item) )
init { limit, endpoint, decoder, headers, queryString } =
    Collection.init
        { limit = limit
        , endpoint = endpoint
        , expect = Http.expectJson Response decoder
        , headers = headers
        , queryString = queryString
        }
