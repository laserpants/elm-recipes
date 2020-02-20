module Form.Register exposing (..)

import Form.Error exposing (Error(..))
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
    Form.Model Field Error Data


validate : Validate Field Error Data
validate =
    let
        validateEmail =
            Validate.stringNotEmpty IsEmpty
                |> Validate.andThen (Validate.email NotAValidEmail)

        validateUsername =
            Validate.stringNotEmpty IsEmpty
                |> Validate.andThen (Validate.alphaNumeric NotAlphanumeric)

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
            Validate.stringNotEmpty IsEmpty
                |> Validate.andThen (Validate.atLeastLength 8 PasswordTooShort)

        validatePasswordConfirmation =
            Validate.stringNotEmpty IsEmpty
                |> Validate.andThen (Validate.mustMatchField Password DoesNotMatchPassword)
    in
    Validate.record Data
        |> Validate.inputField Name (Validate.stringNotEmpty IsEmpty)
        |> Validate.inputField Email validateEmail
        |> Validate.inputField Username validateUsername
        |> Validate.inputField PhoneNumber (Validate.stringNotEmpty IsEmpty)
        |> Validate.inputField Password validatePassword
        |> Validate.inputField PasswordConfirmation validatePasswordConfirmation
        |> Validate.checkbox AcceptTerms (Validate.mustBeChecked TermsNotAccepted)


init : FieldList Field Error -> ( Model, Cmd Msg )
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
                [ Html.Attributes.disabled disabled ]
                [ div []
                    [ label [] [ text "Name" ]
                    ]
                , div []
                    [ input
                        (Form.inputAttrs Name name)
                        []
                    , div [] [ errorHelper name ]
                    ]
                , div []
                    [ label [] [ text "Email" ]
                    ]
                , div []
                    [ input
                        (Form.inputAttrs Email email)
                        []
                    , div [] [ errorHelper email ]
                    ]
                , div []
                    [ label [] [ text "Username" ]
                    ]
                , div []
                    [ input
                        (Form.inputAttrs Username username)
                        []
                    , div [] [ errorHelper username ]
                    ]
                , div []
                    [ label [] [ text "Phone number" ]
                    ]
                , div []
                    [ input
                        (Form.inputAttrs PhoneNumber phoneNumber)
                        []
                    , div [] [ errorHelper phoneNumber ]
                    ]
                , div []
                    [ label [] [ text "Password" ]
                    ]
                , div []
                    [ input
                        ([ type_ "password" ] ++ Form.inputAttrs Password password)
                        []
                    , div [] [ errorHelper password ]
                    ]
                , div []
                    [ label [] [ text "Confirm password" ]
                    ]
                , div []
                    [ input
                        ([ type_ "password" ] ++ Form.inputAttrs PasswordConfirmation passwordConfirmation)
                        []
                    , div [] [ errorHelper passwordConfirmation ]
                    ]
                , div []
                    [ label [] [ text "Accept terms" ]
                    ]
                , div []
                    [ input
                        ([ type_ "checkbox" ] ++ Form.checkboxAttrs AcceptTerms acceptTerms)
                        []
                    ]
                , div []
                    [ button []
                        [ text "Send"
                        ]
                    ]
                ]
            ]
                |> Html.form [ onSubmit Form.Submit ]
        )
