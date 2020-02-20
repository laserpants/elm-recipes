module Data.Session exposing (Session, decoder, encoder)

import Data.User as User exposing (User)
import Json.Decode as Json exposing (field)
import Json.Encode as Encode exposing (Value, object)


type alias Session =
    { user : User
    }


decoder : Json.Decoder Session
decoder =
    Json.map Session (field "user" User.decoder)


encoder : Session -> Value
encoder { user } =
    object
        [ ( "user", User.encoder user )
        ]
