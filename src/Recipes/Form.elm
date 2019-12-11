module Recipes.Form exposing (Field, FieldList, Model, ModelExtra, Msg(..), Status(..), Validate, Variant(..), asBool, asString, checkbox, checkboxAttrs, fieldError, init, initExtra, inputAttrs, inputField, lookup2, lookup3, lookup4, lookup5, lookup6, lookup7, lookupField, reset, run, setFieldDirty, setState, update, validateField)

import Html exposing (Html, text)
import Html.Attributes as Attributes
import Html.Events exposing (onBlur, onCheck, onFocus, onInput)
import Maybe.Extra as Maybe
import Recipes.Helpers exposing (Bundle, andCall, runBundle)
import Update.Pipeline exposing (andThen, save)


type Variant
    = String String
    | Bool Bool


asString : Variant -> String
asString var =
    case var of
        String string ->
            string

        _ ->
            ""


asBool : Variant -> Bool
asBool var =
    case var of
        Bool bool ->
            bool

        _ ->
            False


type Msg field
    = Focus field
    | Blur field
    | Input field Variant
    | Submit


type Status err
    = Pristine
    | Valid
    | Error err


type alias Field err =
    { value : Variant
    , dirty : Bool
    , status : Status err
    , submitted : Bool
    }


fieldError : Field err -> Maybe err
fieldError { status, dirty, submitted } =
    case status of
        Error error ->
            if not dirty || submitted then
                Just error

            else
                Nothing

        _ ->
            Nothing


inputAttrs : field -> Field err -> List (Html.Attribute (Msg field))
inputAttrs tag { value } =
    [ onInput (Input tag << String)
    , onFocus (Focus tag)
    , onBlur (Blur tag)
    , Attributes.value (asString value)
    ]


checkboxAttrs : field -> Field err -> List (Html.Attribute (Msg field))
checkboxAttrs tag { value } =
    [ onCheck (Input tag << Bool)
    , onFocus (Focus tag)
    , onBlur (Blur tag)
    , Attributes.checked (asBool value)
    ]


inputField : String -> Field err
inputField string =
    { value = String string
    , dirty = False
    , status = Pristine
    , submitted = False
    }


checkbox : Bool -> Field err
checkbox bool =
    { value = Bool bool
    , dirty = False
    , status = Pristine
    , submitted = False
    }


type alias FieldList field err =
    List ( field, Field err )


type alias Validate field err data =
    Maybe field
    -> FieldList field err
    -> ( FieldList field err, Maybe data, Maybe field )


type alias ModelExtra field err data state =
    { fields : FieldList field err
    , initial : FieldList field err
    , validate : state -> Validate field err data
    , disabled : Bool
    , submitted : Bool
    , state : state
    }


type alias Model field err data =
    ModelExtra field err data ()


setFields :
    FieldList field err
    -> ( ModelExtra field err data state, List a )
    -> ( ( ModelExtra field err data state, List a ), Cmd (Msg field) )
setFields fields ( model, calls ) =
    save ( { model | fields = fields }, calls )


applyToField :
    field
    -> (Field err -> Field err)
    -> FieldList field err
    -> FieldList field err
applyToField target fun =
    List.map
        (\( tag, field ) ->
            ( tag
            , if tag == target then
                fun field

              else
                field
            )
        )


setSubmitted :
    Bool
    -> ( ModelExtra field err data state, List a )
    -> ( ( ModelExtra field err data state, List a ), Cmd (Msg field) )
setSubmitted submitted ( model, calls ) =
    save ( { model | submitted = submitted }, calls )


setDisabled :
    Bool
    -> ( ModelExtra field err data state, List a )
    -> ( ( ModelExtra field err data state, List a ), Cmd (Msg field) )
setDisabled disabled ( model, calls ) =
    save ( { model | disabled = disabled }, calls )


lookupField :
    field
    -> FieldList field err
    -> Maybe (Field err)
lookupField target fields =
    let
        rec list =
            case list of
                [] ->
                    Nothing

                ( tag, field ) :: xs ->
                    if tag == target then
                        Just field

                    else
                        rec xs
    in
    rec fields


withField :
    field
    -> (Field err -> Field err)
    -> ( ModelExtra field err data state, List a )
    -> ( ( ModelExtra field err data state, List a ), Cmd (Msg field) )
withField target fun ( { fields } as model, calls ) =
    ( model, calls )
        |> setFields (applyToField target fun fields)


validateField :
    field
    -> ( ModelExtra field err data state, List a )
    -> ( ( ModelExtra field err data state, List a ), Cmd (Msg field) )
validateField field ( { validate, state, fields } as model, calls ) =
    let
        updateFields ( newFields, _, _ ) =
            setFields newFields ( model, calls )
    in
    fields
        |> validate state (Just field)
        |> updateFields


run :
    (Msg field -> msg)
    -> Bundle (Model field err data) (Msg field) { a | form : Model field err data } msg
    -> { a | form : Model field err data }
    -> ( { a | form : Model field err data }, Cmd msg )
run =
    let
        setForm form model =
            { model | form = form }
    in
    runBundle .form setForm


initExtra :
    (state -> Validate field err data)
    -> FieldList field err
    -> state
    -> ( ModelExtra field err data state, Cmd (Msg field) )
initExtra validate fields state =
    save
        { fields = fields
        , initial = fields
        , validate = validate
        , disabled = False
        , submitted = False
        , state = state
        }


init :
    Validate field err data
    -> FieldList field err
    -> ( Model field err data, Cmd (Msg field) )
init validate fields =
    initExtra (always validate) fields ()


reset :
    ModelExtra field err data state
    -> ( ( ModelExtra field err data state, List a ), Cmd (Msg field) )
reset model =
    save
        ( { model
            | fields = model.initial
            , disabled = False
            , submitted = False
          }
        , []
        )


setState :
    state
    -> ModelExtra field err data state
    -> ( ( ModelExtra field err data state, List a ), Cmd (Msg field) )
setState state model =
    save ( { model | state = state }, [] )


setFieldDirty :
    field
    -> Bool
    -> ModelExtra field err data state
    -> ( ( ModelExtra field err data state, List a ), Cmd (Msg field) )
setFieldDirty tag dirty model =
    ( model, [] )
        |> withField tag (\field -> { field | dirty = dirty })


update :
    Msg field
    -> { onSubmit : data -> a }
    -> ModelExtra field err data state
    -> ( ( ModelExtra field err data state, List a ), Cmd (Msg field) )
update msg { onSubmit } ({ fields, validate, state } as model) =
    let
        handleSubmit maybeData =
            case maybeData of
                Just data ->
                    setDisabled True
                        >> andCall (onSubmit data)

                Nothing ->
                    save
    in
    (case msg of
        Submit ->
            let
                fieldSetSubmitted field =
                    { field
                        | dirty = True
                        , submitted = True
                    }
            in
            fields
                |> List.map (Tuple.mapSecond fieldSetSubmitted)
                |> validate state Nothing

        Input target value ->
            let
                fieldSetValue field =
                    { field
                        | value = value
                        , dirty = True
                    }
            in
            fields
                |> applyToField target fieldSetValue
                |> validate state (Just target)

        Blur target ->
            fields
                |> applyToField target (\field -> { field | dirty = False })
                |> validate state (Just target)

        Focus _ ->
            ( fields, Nothing, Nothing )
    )
        |> (\( newFields, maybeData, _ ) ->
                ( model, [] )
                    |> setFields newFields
                    |> andThen
                        (if Submit == msg then
                            setSubmitted True
                                >> andThen (handleSubmit maybeData)

                         else
                            save
                        )
           )


lookup2 :
    FieldList field err
    -> field
    -> field
    -> (Field err -> Field err -> Html msg)
    -> Html msg
lookup2 fields f1 f2 fun =
    Maybe.withDefault (text "")
        (Maybe.map2 fun
            (lookupField f1 fields)
            (lookupField f2 fields)
        )


lookup3 :
    FieldList field err
    -> field
    -> field
    -> field
    -> (Field err -> Field err -> Field err -> Html msg)
    -> Html msg
lookup3 fields f1 f2 f3 fun =
    Maybe.withDefault (text "")
        (Maybe.map3 fun
            (lookupField f1 fields)
            (lookupField f2 fields)
            (lookupField f3 fields)
        )


lookup4 :
    FieldList field err
    -> field
    -> field
    -> field
    -> field
    -> (Field err -> Field err -> Field err -> Field err -> Html msg)
    -> Html msg
lookup4 fields f1 f2 f3 f4 fun =
    Maybe.withDefault (text "")
        (Maybe.map4 fun
            (lookupField f1 fields)
            (lookupField f2 fields)
            (lookupField f3 fields)
            (lookupField f4 fields)
        )


lookup5 :
    FieldList field err
    -> field
    -> field
    -> field
    -> field
    -> field
    -> (Field err -> Field err -> Field err -> Field err -> Field err -> Html msg)
    -> Html msg
lookup5 fields f1 f2 f3 f4 f5 fun =
    Maybe.withDefault (text "")
        (Maybe.map5 fun
            (lookupField f1 fields)
            (lookupField f2 fields)
            (lookupField f3 fields)
            (lookupField f4 fields)
            (lookupField f5 fields)
        )


lookup6 :
    FieldList field err
    -> field
    -> field
    -> field
    -> field
    -> field
    -> field
    -> (Field err -> Field err -> Field err -> Field err -> Field err -> Field err -> Html msg)
    -> Html msg
lookup6 fields f1 f2 f3 f4 f5 f6 fun =
    Maybe.withDefault (text "")
        (Just fun
            |> Maybe.andMap (lookupField f1 fields)
            |> Maybe.andMap (lookupField f2 fields)
            |> Maybe.andMap (lookupField f3 fields)
            |> Maybe.andMap (lookupField f4 fields)
            |> Maybe.andMap (lookupField f5 fields)
            |> Maybe.andMap (lookupField f6 fields)
        )


lookup7 :
    FieldList field err
    -> field
    -> field
    -> field
    -> field
    -> field
    -> field
    -> field
    -> (Field err -> Field err -> Field err -> Field err -> Field err -> Field err -> Field err -> Html msg)
    -> Html msg
lookup7 fields f1 f2 f3 f4 f5 f6 f7 fun =
    Maybe.withDefault (text "")
        (Just fun
            |> Maybe.andMap (lookupField f1 fields)
            |> Maybe.andMap (lookupField f2 fields)
            |> Maybe.andMap (lookupField f3 fields)
            |> Maybe.andMap (lookupField f4 fields)
            |> Maybe.andMap (lookupField f5 fields)
            |> Maybe.andMap (lookupField f6 fields)
            |> Maybe.andMap (lookupField f7 fields)
        )
