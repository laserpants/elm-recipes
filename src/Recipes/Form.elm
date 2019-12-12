module Recipes.Form exposing (Field, FieldDict, Model, ModelEnhanced, Msg(..), Status(..), Validate, Variant(..), asBool, asString, checkbox, checkboxAttrs, fieldError, init, initEnhanced, inputAttrs, inputField, lookup2, lookup3, lookup4, lookup5, lookup6, lookup7, lookupField, reset, run, setFieldDirty, setState, update, validateField)

import AssocList as Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events exposing (onBlur, onCheck, onFocus, onInput)
import Maybe.Extra as Maybe
import Recipes.Helpers exposing (Bundle, andCall, runBundle, saveLifted)
import Update.Pipeline exposing (andThen, andThenIf, save)


type Variant
    = String String
    | Bool Bool
    | Null


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


nullField : Field err
nullField =
    { value = Null
    , status = Pristine
    , dirty = False
    , submitted = False
    }


withDefaultNullField : Maybe (Field err) -> Field err
withDefaultNullField =
    Maybe.withDefault nullField


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


type alias FieldDict f e =
    Dict f (Field e)


type alias Validate f e d =
    Maybe f
    -> FieldDict f e
    -> ( FieldDict f e, Maybe d, Maybe f )


type alias ModelEnhanced f e d s =
    { fields : FieldDict f e
    , initial : FieldDict f e
    , validate : s -> Validate f e d
    , disabled : Bool
    , submitted : Bool
    , state : s
    }


type alias Model f e d =
    ModelEnhanced f e d ()


setFields :
    FieldDict f e
    -> ( ModelEnhanced f e d s, List a )
    -> ( ( ModelEnhanced f e d s, List a ), Cmd (Msg f) )
setFields fields ( model, calls ) =
    save ( { model | fields = fields }, calls )


applyToField : f -> (Field e -> Field e) -> FieldDict f e -> FieldDict f e
applyToField target fun =
    Dict.update target (Just << fun << withDefaultNullField)


setSubmitted :
    Bool
    -> ( ModelEnhanced f e d s, List a )
    -> ( ( ModelEnhanced f e d s, List a ), Cmd (Msg f) )
setSubmitted submitted ( model, calls ) =
    save ( { model | submitted = submitted }, calls )


setDisabled :
    Bool
    -> ( ModelEnhanced f e d s, List a )
    -> ( ( ModelEnhanced f e d s, List a ), Cmd (Msg f) )
setDisabled disabled ( model, calls ) =
    save ( { model | disabled = disabled }, calls )


lookupField : field -> FieldDict field err -> Field err
lookupField target =
    withDefaultNullField << Dict.get target


withField :
    f
    -> (Field e -> Field e)
    -> ( ModelEnhanced f e d s, List a )
    -> ( ( ModelEnhanced f e d s, List a ), Cmd (Msg f) )
withField target fun ( { fields } as model, calls ) =
    ( model, calls )
        |> setFields (applyToField target fun fields)


validateField :
    f
    -> ModelEnhanced f e d s
    -> ( ( ModelEnhanced f e d s, List a ), Cmd (Msg f) )
validateField field ({ validate, state, fields } as model) =
    let
        updateFields ( newFields, _, _ ) =
            setFields newFields ( model, [] )
    in
    fields
        |> validate state (Just field)
        |> updateFields


run :
    (Msg f -> msg)
    -> Bundle (Model f e d) (Msg f) { a | form : Model f e d } msg
    -> { a | form : Model f e d }
    -> ( { a | form : Model f e d }, Cmd msg )
run =
    let
        setForm form model =
            { model | form = form }
    in
    runBundle .form setForm


initEnhanced :
    (s -> Validate f e d)
    -> List ( f, Field e )
    -> s
    -> ( ModelEnhanced f e d s, Cmd (Msg f) )
initEnhanced validate fields state =
    let
        fieldsDict =
            Dict.fromList fields
    in
    save
        { fields = fieldsDict
        , initial = fieldsDict
        , validate = validate
        , disabled = False
        , submitted = False
        , state = state
        }


init : Validate f e d -> List ( f, Field e ) -> ( Model f e d, Cmd (Msg f) )
init validate fields =
    initEnhanced (always validate) fields ()


reset : ModelEnhanced f e d s -> ( ( ModelEnhanced f e d s, List a ), Cmd (Msg f) )
reset model =
    saveLifted
        { model
            | fields = model.initial
            , disabled = False
            , submitted = False
        }


setState : s -> ModelEnhanced f e d s -> ( ( ModelEnhanced f e d s, List a ), Cmd (Msg f) )
setState state model =
    saveLifted { model | state = state }


setFieldDirty :
    f
    -> Bool
    -> ModelEnhanced f e d s
    -> ( ( ModelEnhanced f e d s, List a ), Cmd (Msg f) )
setFieldDirty tag dirty model =
    ( model, [] )
        |> withField tag (\field -> { field | dirty = dirty })


update :
    Msg f
    -> { onSubmit : d -> a }
    -> ModelEnhanced f e d s
    -> ( ( ModelEnhanced f e d s, List a ), Cmd (Msg f) )
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
                fieldSetSubmitted _ field =
                    { field
                        | dirty = True
                        , submitted = True
                    }
            in
            fields
                |> Dict.map fieldSetSubmitted
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
                    |> andThenIf (Submit == msg)
                        (setSubmitted True >> andThen (handleSubmit maybeData))
           )


lookup2 :
    FieldDict field err
    -> field
    -> field
    -> (Field err -> Field err -> Html msg)
    -> Html msg
lookup2 fields f1 f2 fun =
    fun
        (lookupField f1 fields)
        (lookupField f2 fields)


lookup3 :
    FieldDict field err
    -> field
    -> field
    -> field
    -> (Field err -> Field err -> Field err -> Html msg)
    -> Html msg
lookup3 fields f1 f2 f3 fun =
    fun
        (lookupField f1 fields)
        (lookupField f2 fields)
        (lookupField f3 fields)


lookup4 :
    FieldDict field err
    -> field
    -> field
    -> field
    -> field
    -> (Field err -> Field err -> Field err -> Field err -> Html msg)
    -> Html msg
lookup4 fields f1 f2 f3 f4 fun =
    fun
        (lookupField f1 fields)
        (lookupField f2 fields)
        (lookupField f3 fields)
        (lookupField f4 fields)


lookup5 :
    FieldDict field err
    -> field
    -> field
    -> field
    -> field
    -> field
    -> (Field err -> Field err -> Field err -> Field err -> Field err -> Html msg)
    -> Html msg
lookup5 fields f1 f2 f3 f4 f5 fun =
    fun
        (lookupField f1 fields)
        (lookupField f2 fields)
        (lookupField f3 fields)
        (lookupField f4 fields)
        (lookupField f5 fields)


lookup6 :
    FieldDict field err
    -> field
    -> field
    -> field
    -> field
    -> field
    -> field
    -> (Field err -> Field err -> Field err -> Field err -> Field err -> Field err -> Html msg)
    -> Html msg
lookup6 fields f1 f2 f3 f4 f5 f6 fun =
    fun
        (lookupField f1 fields)
        (lookupField f2 fields)
        (lookupField f3 fields)
        (lookupField f4 fields)
        (lookupField f5 fields)
        (lookupField f6 fields)


lookup7 :
    FieldDict field err
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
    fun
        (lookupField f1 fields)
        (lookupField f2 fields)
        (lookupField f3 fields)
        (lookupField f4 fields)
        (lookupField f5 fields)
        (lookupField f6 fields)
        (lookupField f7 fields)
