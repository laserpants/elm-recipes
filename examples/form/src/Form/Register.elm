module Form.Register exposing (..)

import Form.Data.Register exposing (Data)
import Form.Error as Error exposing (Error(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Recipes.Form as Form exposing (Validate, checkbox, inputField)
import Recipes.Form.Validate as Validate


type Fields
    = Name
    | Email
    | PhoneNumber
    | Password
    | PasswordConfirmation
    | AcceptTerms


type alias Msg =
    Form.Msg Fields


type alias Model =
    Form.Model Fields Error Data


init : ( Model, Cmd msg )
init =
    Form.init validate []


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
        |> Validate.checkbox AcceptTerms (Validate.mustBeChecked MustAcceptTerms)


view : Model -> Html Msg
view { fields, disabled } =
    let
        errorHelper field =
            case Form.fieldError field of
                Nothing ->
                    text ""

                Just error ->
                    text (Error.toString error)
    in
    Form.lookup6 fields
        Name
        Email
        PhoneNumber
        Password
        PasswordConfirmation
        AcceptTerms
        (\name email phoneNumber password passwordConfirmation acceptTerms ->
            [ fieldset
                [ Html.Attributes.disabled disabled ]
                [ div []
                    [ div [] [ label [] [ text "Name" ] ]
                    , div [] [ input (Form.inputAttrs Name name) [] ]
                    , div [] [ errorHelper name ]
                    ]
                , div []
                    [ div [] [ label [] [ text "Email" ] ]
                    , div [] [ input (Form.inputAttrs Email email) [] ]
                    , div [] [ errorHelper email ]
                    ]
                , div []
                    [ div [] [ label [] [ text "Phone number" ] ]
                    , div [] [ input (Form.inputAttrs PhoneNumber phoneNumber) [] ]
                    , div [] [ errorHelper phoneNumber ]
                    ]
                , div []
                    [ div [] [ label [] [ text "Password" ] ]
                    , div [] [ input (type_ "password" :: Form.inputAttrs Password password) [] ]
                    , div [] [ errorHelper password ]
                    ]
                , div []
                    [ div [] [ label [] [ text "Confirm password" ] ]
                    , div [] [ input (type_ "password" :: Form.inputAttrs PasswordConfirmation passwordConfirmation) [] ]
                    , div [] [ errorHelper passwordConfirmation ]
                    ]
                , div []
                    [ div [] [ input (type_ "checkbox" :: Form.checkboxAttrs AcceptTerms acceptTerms) [] ]
                    , div [] [ text "I agree with terms and conditions" ]
                    , div [] [ errorHelper acceptTerms ]
                    ]
                , div []
                    [ button []
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
                |> Html.form [ onSubmit Form.Submit ]
        )
