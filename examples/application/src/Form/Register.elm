module Form.Register exposing (..)

import Bulma.Form exposing (controlCheckBox, controlHelp, controlInput, controlLabel)
import Bulma.Modifiers exposing (Color(..))
import Form.Error exposing (Error(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Json.Encode as Encode
import Recipes.Form as Form exposing (FieldList, Validate, checkbox, inputField)
import Recipes.Form.Validate as Validate
import Util.Form


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


type UsernameStatus
    = Blank
    | IsAvailable Bool
    | Unknown


type alias Model =
    Form.ModelState Field Error Data UsernameStatus


validate : UsernameStatus -> Validate Field Error Data
validate usernameStatus =
    let
        validateEmail =
            Validate.stringNotEmpty IsEmpty
                |> Validate.andThen (Validate.email NotAValidEmail)

        validateUsername =
            Validate.stringNotEmpty IsEmpty
                |> Validate.andThen (Validate.alphaNumeric NotAlphanumeric)
                |> Validate.andThen
                    (always
                        << (case usernameStatus of
                                IsAvailable False ->
                                    always (Err UsernameTaken)

                                _ ->
                                    Ok
                           )
                    )

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
        |> Validate.inputField PhoneNumber (always << Ok)
        |> Validate.inputField Password validatePassword
        |> Validate.inputField PasswordConfirmation validatePasswordConfirmation
        |> Validate.checkbox AcceptTerms (Validate.mustBeChecked TermsNotAccepted)


init : FieldList Field Error -> ( Model, Cmd Msg )
init fields =
    Form.initState validate fields Blank


view : Model -> Html Msg
view { fields, disabled, state } =
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
                [ Bulma.Form.field []
                    [ controlLabel [] [ text "Name" ]
                    , Util.Form.controlInput Name name "Name"
                    , Util.Form.controlErrorHelp name
                    ]
                , Bulma.Form.field []
                    [ controlLabel [] [ text "Email" ]
                    , Util.Form.controlInput Email email "Email"
                    , Util.Form.controlErrorHelp email
                    ]
                , Bulma.Form.field []
                    [ controlLabel [] [ text "Username" ]
                    , Util.Form.control
                        (if Unknown == state then
                            [ class "is-loading" ]

                         else
                            []
                        )
                        (if IsAvailable True == state then
                            [ class "is-success" ]

                         else
                            []
                        )
                        []
                        controlInput
                        Username
                        username
                        "Username"
                    , Util.Form.controlErrorHelp username
                    , if Form.Valid == username.status && IsAvailable True == state then
                        controlHelp Success [] [ text "This username is available" ]

                      else
                        text ""
                    ]
                , Bulma.Form.field []
                    [ controlLabel [] [ text "Phone number" ]
                    , Util.Form.controlInput PhoneNumber phoneNumber "Phone number"
                    , Util.Form.controlErrorHelp phoneNumber
                    ]
                , Bulma.Form.field []
                    [ controlLabel [] [ text "Password" ]
                    , Util.Form.controlPassword Password password "Password"
                    , Util.Form.controlErrorHelp password
                    ]
                , Bulma.Form.field []
                    [ controlLabel [] [ text "Confirm password" ]
                    , Util.Form.controlPassword PasswordConfirmation passwordConfirmation "Confirm password"
                    , Util.Form.controlErrorHelp passwordConfirmation
                    ]
                , Bulma.Form.field []
                    [ controlCheckBox False
                        []
                        (Form.checkboxAttrs AcceptTerms acceptTerms)
                        []
                        [ text "I accept the terms and conditions" ]
                    , Util.Form.controlErrorHelp acceptTerms
                    ]
                , Bulma.Form.field []
                    [ div [ class "control" ]
                        [ button
                            [ class "button is-primary" ]
                            [ text
                                (if disabled then
                                    "Please wait"

                                 else
                                    "Send"
                                )
                            ]
                        ]
                    ]
                ]
            ]
                |> Html.form [ onSubmit Form.Submit ]
        )
