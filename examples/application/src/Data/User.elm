module Data.User exposing (User, decoder, encoder)

import Json.Decode as Json exposing (bool, field, int, string)
import Json.Encode as Encode exposing (Value, object)


type alias User =
    { id : Maybe Int
    , name : String
    , email : String
    , rememberMe : Bool
    }


decoder : Json.Decoder User
decoder =
    Json.map4 User
        (Json.maybe (field "id" int))
        (field "name" string)
        (field "email" string)
        (field "rememberMe" bool)


encoder : User -> Value
encoder { id, name, email, rememberMe } =
    let
        maybeId =
            case id of
                Just id_ ->
                    [ ( "id", Encode.int id_ ) ]

                Nothing ->
                    []

        payload =
            [ ( "name", Encode.string name )
            , ( "email", Encode.string email )
            , ( "rememberMe", Encode.bool rememberMe )
            ]
    in
    object (maybeId ++ payload)
