module Data.WebSocket.UsernameAvailable exposing (..)

import Json.Decode as Json exposing (bool, field, string)


responseAtom : String
responseAtom =
    "username_available_response"


type alias Response =
    { username : String
    , isAvailable : Bool
    }


responseDecoder : Json.Decoder Response
responseDecoder =
    Json.map2 UsernameAvailableResponse
        (field "username" string)
        (field "is_available" bool)
