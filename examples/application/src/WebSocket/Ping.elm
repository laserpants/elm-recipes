module WebSocket.Ping exposing (..)

import Json.Decode as Json exposing (field)
import Json.Encode as Encode
import Recipes.WebSocket as WebSocket


type alias WsResponse =
    { message : String
    }


responseId : String
responseId =
    "ping_response"


responseDecoder : Json.Decoder WsResponse
responseDecoder =
    Json.map WsResponse
        (field "message" Json.string)


send : m -> ( m, Cmd msg )
send =
    WebSocket.sendMessage "ping" (Encode.object [])
