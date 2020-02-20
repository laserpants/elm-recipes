module Form.Register exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Json.Encode as Encode
import Recipes.Form as Form exposing (FieldList, Validate, checkbox, inputField)
import Recipes.Form.Validate as Validate


type Field
    = Name
    | Email
    | Username
    | PhoneNumber
    | Password
    | PasswordConfirmation
    | AcceptTerms


type alias Msg =
    Form.Msg Field


type alias Data =
    { name : String
    , email : String
    , username : String
    , phoneNumber : String
    , password : String
    , passwordConfirmation : String
    , acceptTerms : Bool
    }


toJson : Data -> Json.Value
toJson { name, email, username, phoneNumber, password, acceptTerms } =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "email", Encode.string email )
        , ( "username", Encode.string username )
        , ( "phoneNumber", Encode.string phoneNumber )
        , ( "password", Encode.string password )
        , ( "acceptTerms", Encode.bool acceptTerms )
        ]


type alias Model =
    Form.Model Field () Data


validate : Validate Field () Data
validate =
    let
        validateEmail =
            Validate.stringNotEmpty ()
                |> Validate.andThen (Validate.email ())

        validateUsername =
            Validate.stringNotEmpty ()
                |> Validate.andThen (Validate.alphaNumeric ())

        --                |> Validate.andThen
        --                    (always
        --                        << (case usernameStatus of
        --                                IsAvailable False ->
        --                                    always (Err UsernameTaken)
        --
        --                                _ ->
        --                                    Ok
        --                           )
        --                    )
        validatePassword =
            Validate.stringNotEmpty ()
                |> Validate.andThen (Validate.atLeastLength 8 ())

        validatePasswordConfirmation =
            Validate.stringNotEmpty ()
                |> Validate.andThen (Validate.mustMatchField Password ())
    in
    Validate.record Data
        |> Validate.inputField Name (Validate.stringNotEmpty ())
        |> Validate.inputField Email validateEmail
        |> Validate.inputField Username validateUsername
        |> Validate.inputField PhoneNumber (Validate.stringNotEmpty ())
        |> Validate.inputField Password validatePassword
        |> Validate.inputField PasswordConfirmation validatePasswordConfirmation
        |> Validate.checkbox AcceptTerms (Validate.mustBeChecked ())


init : FieldList Field () -> ( Model, Cmd Msg )
init =
    Form.init validate


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
    Form.lookup7 fields
        Name
        Email
        Username
        PhoneNumber
        Password
        PasswordConfirmation
        AcceptTerms
        (\name email username phoneNumber password passwordConfirmation acceptTerms ->
            [ fieldset
                []
                []

            --                [ Html.Attributes.disabled disabled ]
            --                [ div []
            --                    [ label [] [ text "Email" ]
            --                    ]
            --                , div []
            --                    [ input
            --                        (Form.inputAttrs Email email)
            --                        []
            --                    , div [] [ errorHelper email ]
            --                    ]
            --                , div []
            --                    [ label [] [ text "Password" ]
            --                    ]
            --                , div []
            --                    [ input
            --                        ([ type_ "password" ] ++ Form.inputAttrs Password password)
            --                        []
            --                    , div [] [ errorHelper password ]
            --                    ]
            --                , div []
            --                    [ label [] [ text "Rememer me" ]
            --                    ]
            --                , div []
            --                    [ input
            --                        ([ type_ "checkbox" ] ++ Form.checkboxAttrs RememberMe rememberMe)
            --                        []
            --                    ]
            --                , div []
            --                    [ button []
            --                        [ text "Log in"
            --                        ]
            --                    ]
            --                ]
            ]
                |> Html.form [ onSubmit Form.Submit ]
        )
