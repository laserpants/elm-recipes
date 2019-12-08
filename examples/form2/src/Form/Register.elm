module Form.Register exposing (..)

import Form.Error exposing (Error(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Json.Encode as Encode
import Update.Form as Form exposing (..)
import Update.Form.Validate as Validate


type Fields
    = Name
    | Email
    | PhoneNumber
    | Password
    | PasswordConfirmation
    | AgreeWithTerms


type alias Msg =
    Form.Msg Fields


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


type alias Model =
    Form.Model Fields Error Data


init : ( Model, Cmd Msg )
init =
    let
        fields =
            [ ( Name, inputField "" )
            , ( Email, inputField "" )
            , ( PhoneNumber, inputField "" )
            , ( Password, inputField "" )
            , ( PasswordConfirmation, inputField "" )
            , ( AgreeWithTerms, checkbox False )
            ]
    in
    Form.init validate fields


validate : Validate Fields Error Data
validate =
    let
        validateEmail =
            Validate.stringNotEmpty MustNotBeEmpty
                |> Validate.andThen (Validate.email MustBeValidEmail)

        validatePassword =
            Validate.stringNotEmpty MustNotBeEmpty
                |> Validate.andThen (Validate.atLeastLength 8 PasswordTooShort)

        validatePasswordConfirmation =
            Validate.stringNotEmpty MustNotBeEmpty
                |> Validate.andThen (Validate.mustMatchField Password MustMatchPassword)
    in
    Validate.record Data
        |> Validate.inputField Name (Validate.stringNotEmpty MustNotBeEmpty)
        |> Validate.inputField Email validateEmail
        |> Validate.inputField PhoneNumber (Validate.stringNotEmpty MustNotBeEmpty)
        |> Validate.inputField Password validatePassword
        |> Validate.inputField PasswordConfirmation validatePasswordConfirmation
        |> Validate.checkbox AgreeWithTerms (Validate.mustBeChecked MustAgreeWithTerms)


view : Model -> Html Msg
view { fields, disabled, state } =
    Form.lookup6 fields
        Name
        Email
        PhoneNumber
        Password
        PasswordConfirmation
        AgreeWithTerms
        (\name email phoneNumber password passwordConfirmation agreeWithTerms ->
            [ fieldset
                [ Html.Attributes.disabled disabled ]
                [ div
                    []
                    [ label [] [ text "Name" ]
                    ]
                ]

            --                [ Bulma.Form.field []
            --                    [ controlLabel [] [ text "Name" ]
            --                    , Helpers.Form.controlInput Name name "Name"
            --                    , Helpers.Form.controlErrorHelp name
            --                    ]
            --                , Bulma.Form.field []
            --                    [ controlLabel [] [ text "Email" ]
            --                    , Helpers.Form.controlInput Email email "Email"
            --                    , Helpers.Form.controlErrorHelp email
            --                    ]
            --                , Bulma.Form.field []
            --                    [ controlLabel [] [ text "Username" ]
            --                    , Helpers.Form.control
            --                        (if Unknown == state then
            --                            [ class "is-loading" ]
            --
            --                         else
            --                            []
            --                        )
            --                        (if IsAvailable True == state then
            --                            [ class "is-success" ]
            --
            --                         else
            --                            []
            --                        )
            --                        []
            --                        controlInput
            --                        Username
            --                        username
            --                        "Username"
            --                    , Helpers.Form.controlErrorHelp username
            --                    , if Form.Valid == username.status && IsAvailable True == state then
            --                        controlHelp Success [] [ text "This username is available" ]
            --
            --                      else
            --                        empty
            --                    ]
            --                , Bulma.Form.field []
            --                    [ controlLabel [] [ text "Phone number" ]
            --                    , Helpers.Form.controlInput PhoneNumber phoneNumber "Phone number"
            --                    , Helpers.Form.controlErrorHelp phoneNumber
            --                    ]
            --                , Bulma.Form.field []
            --                    [ controlLabel [] [ text "Password" ]
            --                    , Helpers.Form.controlPassword Password password "Password"
            --                    , Helpers.Form.controlErrorHelp password
            --                    ]
            --                , Bulma.Form.field []
            --                    [ controlLabel [] [ text "Confirm password" ]
            --                    , Helpers.Form.controlPassword PasswordConfirmation passwordConfirmation "Confirm password"
            --                    , Helpers.Form.controlErrorHelp passwordConfirmation
            --                    ]
            --                , Bulma.Form.field []
            --                    [ controlCheckBox False
            --                        []
            --                        (Form.checkboxAttrs AgreeWithTerms agreeWithTerms)
            --                        []
            --                        [ text "I agree with terms and conditions" ]
            --                    , Helpers.Form.controlErrorHelp agreeWithTerms
            --                    ]
            --                , Bulma.Form.field []
            --                    [ div [ class "control" ]
            --                        [ button
            --                            [ class "button is-primary" ]
            --                            [ text
            --                                (if disabled then
            --                                    "Please wait"
            --
            --                                 else
            --                                    "Send"
            --                                )
            --                            ]
            --                        ]
            --                    ]
            --                ]
            ]
                |> Html.form [ onSubmit Form.Submit ]
        )
