module Data.Websocket.UsernameAvailableResponse exposing (..)

import Json.Decode as Json exposing (bool, field, string)


atom : String
atom =
    "username_available_response"


type alias UsernameAvailableResponse =
    { username : String
    , isAvailable : Bool
    }


decoder : Json.Decoder UsernameAvailableResponse
decoder =
    Json.map2 UsernameAvailableResponse
        (field "username" string)
        (field "is_available" bool)
