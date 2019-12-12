module Form.Data.Register exposing (Data, toJson)

import Json.Decode as Json
import Json.Encode as Encode


type alias Data =
    { name : String
    , email : String
    , phoneNumber : String
    , password : String
    , passwordConfirmation : String
    , agreeWithTerms : Bool
    }


toJson : Data -> Json.Value
toJson { name, email, phoneNumber, password, agreeWithTerms } =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "email", Encode.string email )
        , ( "phoneNumber", Encode.string phoneNumber )
        , ( "password", Encode.string password )
        , ( "agreeWithTerms", Encode.bool agreeWithTerms )
        ]
