module Form.NewPost exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Json.Encode as Encode
import Recipes.Form as Form exposing (Validate, checkbox, inputField)
import Recipes.Form.Validate as Validate


type Fields
    = Title
    | Body


type alias Msg =
    Form.Msg Fields


type alias Data =
    { title : String
    , body : String
    }


toJson : Data -> Json.Value
toJson { title, body } =
    Encode.object
        [ ( "title", Encode.string title )
        , ( "body", Encode.string body )
        ]


type alias Model =
    Form.Model Fields () Data


validate : Validate Fields () Data
validate =
    let
        validateTitle =
            Validate.stringNotEmpty ()

        validateBody =
            Validate.stringNotEmpty ()
    in
    Validate.record Data
        |> Validate.inputField Title validateTitle
        |> Validate.inputField Body validateBody


init : List ( Fields, Form.Field () ) -> ( Model, Cmd Msg )
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
        Title
        Body
        (\title body ->
            [ fieldset
                [ Html.Attributes.disabled disabled ]
                [ div []
                    [ label [] [ text "Title" ]
                    ]
                , div []
                    [ input
                        (Form.inputAttrs Title title)
                        []
                    , div [] [ errorHelper title ]
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
