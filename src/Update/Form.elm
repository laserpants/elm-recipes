module Update.Form exposing (..)

import Html exposing (..)
import Html.Attributes as Attributes exposing (..)
import Html.Events exposing (..)
import Maybe.Extra as Maybe
import Update.Pipeline exposing (..)


withCalls : List c -> ( a, Cmd msg ) -> ( a, Cmd msg, List c )
withCalls funs ( model, cmd ) =
    ( model, cmd, funs )


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
    -> ModelExtra field err data state
    -> ( ModelExtra field err data state, Cmd (Msg field) )
setFields fields model =
    save { model | fields = fields }


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


withField : 
    field 
    -> (Field err -> Field err)
    -> ModelExtra field err data state
    -> ( ModelExtra field err data state, Cmd (Msg field) )
withField target fun =
    with .fields (setFields << applyToField target fun)


setSubmitted : 
    Bool 
    -> ModelExtra field err data state
    -> ( ModelExtra field err data state, Cmd (Msg field) )
setSubmitted submitted model =
    save { model | submitted = submitted }


setDisabled : 
    Bool 
    -> ModelExtra field err data state
    -> ( ModelExtra field err data state, Cmd (Msg field) )
setDisabled disabled model =
    save { model | disabled = disabled }


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


setState : 
    state
    -> ModelExtra field err data state
    -> ( ModelExtra field err data state, Cmd (Msg field) )
setState state model =
    save { model | state = state }


type alias Run form msg1 model msg =
    (form -> ( form, Cmd msg1, List (model -> ( model, Cmd msg )) ))
    -> model
    -> ( model, Cmd msg )


runCustom :
    (model -> ModelExtra field err data state)
    -> (ModelExtra field err data state -> model -> model)
    -> (Msg field -> msg)
    -> Run (ModelExtra field err data state) (Msg field) model msg
runCustom get set toMsg updater model =
    let
        ( form, cmd, calls ) =
            updater (get model)
    in
    set form model
        |> sequence calls
        |> andAddCmd (Cmd.map toMsg cmd)


run : (Msg field -> msg) -> Run (Model field err data) (Msg field) { a | form : Model field err data } msg
run =
    let
        setForm form model =
            { model | form = form }
    in
    runCustom .form setForm


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


reset : ModelExtra field err data state -> ( ModelExtra field err data state, Cmd (Msg field) )
reset model =
    save
        { model
            | fields = model.initial
            , disabled = False
            , submitted = False
        }


validateField : 
    field 
    -> ModelExtra field err data state 
    -> ( ModelExtra field err data state, Cmd (Msg field) )
validateField field model =
    let 
        { validate, state, fields } =
            model

        updateFields ( newFields, _, _) =
            setFields newFields model 
    in
    fields
        |> validate state (Just field)
        |> updateFields


setFieldDirty : 
    field 
    -> Bool 
    -> ModelExtra field err data state 
    -> ( ModelExtra field err data state, Cmd (Msg field) )
setFieldDirty tag dirty =
    withField tag (\field -> { field | dirty = dirty })


update : 
    Msg field 
    -> { onSubmit : data -> a } 
    -> ModelExtra field err data state
    -> ( ModelExtra field err data state, Cmd (Msg field), List (model -> ( model, Cmd msg )) )
update msg { onSubmit } model =
    let 
        { fields, validate, state } =
            model

        bananas = 
            case msg of
                Submit ->
                    Debug.todo ""

                Input target value ->
                    Debug.todo ""

                Blur target ->
                    Debug.todo ""

                Focus _ ->
                    Debug.todo ""

        handleSubmit maybeData m_ =
            case maybeData of
               Just data ->
                   Debug.todo ""
                   
                   --setDisabled True
                   --    >> Debug.todo "" -- withCalls [ onSubmit data ]

               Nothing ->
                   Debug.todo ""
                   --withCalls [] (save m_)


    in
    bananas
        |> (\( newFields, maybeData, _ ) ->
              model
                  |> setFields newFields
                  |> andThenIf (Submit == msg) 
                      (Debug.todo "")
                       --(setSubmitted True >> andThen (handleSubmit maybeData))
                  |> Debug.todo ""

--                     (if Submit == msg then
--                         setSubmitted True
--                             |> andThen
--                                 (case maybeData of
--                                     Just data ->
--                                         Debug.todo ""
--                                         
--                                         --setDisabled True
--                                         --    >> Debug.todo "" -- withCalls [ onSubmit data ]
--
--                                     Nothing ->
--                                         Debug.todo ""
--                                         --save >> withCalls []
--                                 )
--                      else
--                          Debug.todo ""
--                         -- save >> withCalls []
--                     )
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
