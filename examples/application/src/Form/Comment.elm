module Form.Comment exposing (..)

import Form.Error exposing (Error(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Json.Encode as Encode
import Recipes.Form as Form exposing (FieldList, Validate, checkbox, inputField)
import Recipes.Form.Validate as Validate


type Field
    = Email
    | Body


type alias Msg =
    Form.Msg Field


type alias Data =
    { email : String
    , body : String
    }


toJson : Data -> Json.Value
toJson { email, body } =
    Encode.object
        [ ( "email", Encode.string email )
        , ( "body", Encode.string body )
        ]


type alias Model =
    Form.Model Field Error Data


validate : Validate Field Error Data
validate =
    let
        validateEmail =
            Validate.stringNotEmpty IsEmpty

        validateBody =
            Validate.stringNotEmpty IsEmpty
    in
    Validate.record Data
        |> Validate.inputField Email validateEmail
        |> Validate.inputField Body validateBody


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
    Form.lookup2 fields
        Email
        Body
        (\email body ->
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
                    [ label [] [ text "Body" ]
                    ]
                , div []
                    [ textarea
                        (Form.inputAttrs Body body)
                        []
                    , div [] [ errorHelper body ]
                    ]
                , div []
                    [ button []
                        [ text "Publish"
                        ]
                    ]
                ]
            ]
                |> Html.form [ onSubmit Form.Submit ]
        )
