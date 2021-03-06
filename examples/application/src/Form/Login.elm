module Form.Login exposing (..)

import Bulma.Form exposing (controlCheckBox, controlHelp, controlInput, controlLabel)
import Bulma.Modifiers exposing (..)
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
    = Email
    | Password
    | RememberMe


type alias Msg =
    Form.Msg Field


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
    Form.Model Field Error Data


validate : Validate Field Error Data
validate =
    let
        validateEmail =
            Validate.stringNotEmpty IsEmpty
                |> Validate.andThen (Validate.email NotAValidEmail)

        validatePassword =
            Validate.stringNotEmpty IsEmpty
    in
    Validate.record Data
        |> Validate.inputField Email validateEmail
        |> Validate.inputField Password validatePassword
        |> Validate.checkbox RememberMe (always << Ok)


init : FieldList Field Error -> ( Model, Cmd msg )
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
    Form.lookup3 fields
        Email
        Password
        RememberMe
        (\email password rememberMe ->
            [ fieldset
                [ Html.Attributes.disabled disabled ]
                [ Bulma.Form.field []
                    [ controlLabel [] [ text "Email address" ]
                    , Util.Form.controlInput Email email "Email"
                    , Util.Form.controlErrorHelp email
                    ]
                , Bulma.Form.field []
                    [ controlLabel [] [ text "Password" ]
                    , Util.Form.controlPassword Password password "Password"
                    , Util.Form.controlErrorHelp password
                    ]
                , Bulma.Form.field []
                    [ controlCheckBox False
                        []
                        (Form.checkboxAttrs RememberMe rememberMe)
                        []
                        [ text "Remember me" ]
                    , Util.Form.controlErrorHelp rememberMe
                    ]
                , Bulma.Form.field []
                    [ div [ class "control" ]
                        [ button
                            [ class "button is-primary" ]
                            [ text
                                (if disabled then
                                    "Please wait"

                                 else
                                    "Log in"
                                )
                            ]
                        ]
                    ]
                ]
            ]
                |> Html.form [ onSubmit Form.Submit ]
        )
