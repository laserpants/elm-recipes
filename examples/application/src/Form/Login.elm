module Form.Login exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Json.Encode as Encode
import Recipes.Form as Form exposing (Validate, checkbox, inputField)
import Recipes.Form.Validate as Validate


type Fields
    = Email
    | Password
    | RememberMe


type alias Msg =
    Form.Msg Fields


type alias Data =
    { email : String
    , password : String
    , rememberMe : Bool
    }


toJson : Data -> Json.Value
toJson { email, password, rememberMe } =
    Encode.object
        [ ( "email", Encode.string email )
        , ( "password", Encode.string password )
        , ( "rememberMe", Encode.bool rememberMe )
        ]


type alias Model =
    Form.Model Fields () Data


validate : Validate Fields () Data
validate =
    let
        validateEmail =
            Validate.stringNotEmpty ()
                |> Validate.andThen (Validate.email ())

        validatePassword =
            Validate.stringNotEmpty ()
    in
    Validate.record Data
        |> Validate.inputField Email validateEmail
        |> Validate.inputField Password validatePassword
        |> Validate.checkbox RememberMe (always << Ok)


init : ( Model, Cmd Msg )
init =
    Form.init validate []


view : Model -> Html Msg
view { fields, disabled } =
    let
        errorHelper field =
            case Form.fieldError field of
                Nothing ->
                    text ""

                Just error ->
                    text "error"
    in
    Form.lookup3 fields
        Email
        Password
        RememberMe
        (\email password rememberMe ->
            [ fieldset
                [ Html.Attributes.disabled disabled ]
                [ div [] 
                    [ label [] [ text "Email" ] 
                    ]
                , div []
                    [ input
                        (Form.inputAttrs Email email)
                        []
                    , div [] [ errorHelper email ]
                    ]
                , div [] 
                    [ label [] [ text "Password" ] 
                    ]
                , div []
                    [ input
                        (Form.inputAttrs Password password)
                        []
                    , div [] [ errorHelper password ]
                    ]
                , div [] 
                    [ label [] [ text "Rememer me" ] 
                    ]
                , div []
                    [ input
                        ([ type_ "checkbox" ] ++ Form.checkboxAttrs RememberMe rememberMe)
                        []
                    ]
                , div []
                    [ button []
                        [ text "Log in"
                        ]
                    ]
                ]
            ]
                |> Html.form [ onSubmit Form.Submit ]
        )
