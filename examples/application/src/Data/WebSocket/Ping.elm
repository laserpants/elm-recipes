module Data.WebSocket.Ping exposing (..)

import Json.Decode as Json exposing (field)


type alias Response =
    { message : String
    }


responseAtom : String
responseAtom =
    "ping_response"


responseDecoder : Json.Decoder Response
responseDecoder =
    Json.map Response
        (field "message" Json.string)
