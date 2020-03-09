module WebSocket.UsernameAvailable exposing (WsRequest, WsResponse, requestEncoder, requestId, responseDecoder, responseId, sendRequest)

import Json.Decode as Json exposing (bool, field, string)
import Json.Encode as Encode
import Recipes.WebSocket as WebSocket


responseId : String
responseId =
    "username_available_response"


type alias WsResponse =
    { username : String
    , isAvailable : Bool
    }


responseDecoder : Json.Decoder WsResponse
responseDecoder =
    Json.map2 WsResponse
        (field "username" string)
        (field "is_available" bool)


requestId : String
requestId =
    "username_available_request"


type alias WsRequest =
    { username : String
    }


requestEncoder : WsRequest -> Json.Value
requestEncoder { username } =
    Encode.object
        [ ( "username", Encode.string username )
        ]


sendRequest : WsRequest -> m -> ( m, Cmd msg )
sendRequest request =
    WebSocket.sendMessage requestId (requestEncoder request)
