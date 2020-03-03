module Data.WebSocket.PingResponse exposing (..)

import Json.Decode as Json exposing (field)


type alias PingResponse =
    { message : String
    }


atom : String
atom =
    "ping_response"


decoder : Json.Decoder PingResponse
decoder =
    Json.map PingResponse
        (field "message" Json.string)
