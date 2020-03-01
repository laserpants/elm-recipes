module Recipes.Form.Validate exposing (alphaNumeric, andThen, atLeastLength, checkbox, email, inputField, int, mustBeChecked, mustMatchField, record, stringNotEmpty)

import AssocList as Dict
import Recipes.Form exposing (FieldDict, Status(..), Variant(..), asBool, asString, field)
import Regex exposing (Regex)


stepValidate :
    tag
    -> (Variant -> FieldDict tag err -> Result err a2)
    -> ( FieldDict tag err, Maybe (a2 -> a1), Maybe tag )
    -> ( FieldDict tag err, Maybe a1, Maybe tag )
stepValidate target validator ( fields, maybeFun, tag ) =
    let
        field_ =
            field target fields

        ( newField, maybeArg ) =
            case validator field_.value fields of
                Ok result ->
                    ( { field_ | status = Valid }, Just result )

                Err error ->
                    ( { field_ | status = Error error }, Nothing )
    in
    ( if Nothing == tag || Just target == tag then
        Dict.insert target newField fields

      else
        fields
    , Maybe.map2 (<|) maybeFun maybeArg
    , tag
    )


inputField :
    tag
    -> (String -> FieldDict tag err -> Result err a2)
    -> (a -> b -> ( FieldDict tag err, Maybe (a2 -> a1), Maybe tag ))
    -> a
    -> b
    -> ( FieldDict tag err, Maybe a1, Maybe tag )
inputField target validator f a b =
    stepValidate target (validator << asString) (f a b)


checkbox :
    tag
    -> (Bool -> FieldDict tag err -> Result err a2)
    -> (a -> b -> ( FieldDict tag err, Maybe (a2 -> a1), Maybe tag ))
    -> a
    -> b
    -> ( FieldDict tag err, Maybe a1, Maybe tag )
checkbox target validator f a b =
    stepValidate target (validator << asBool) (f a b)


record : a -> b -> c -> ( c, Maybe a, b )
record a b c =
    ( c, Just a, b )


andThen :
    (b -> FieldDict tag err -> Result err c)
    -> (a -> FieldDict tag err -> Result err b)
    -> a
    -> FieldDict tag err
    -> Result err c
andThen next first a fields =
    fields
        |> first a
        |> Result.andThen (\b -> next b fields)


int : err -> Variant -> FieldDict tag err -> Result err Int
int error variant _ =
    case variant of
        String str ->
            Result.fromMaybe error (String.toInt str)

        _ ->
            Err error


stringNotEmpty : err -> String -> FieldDict tag err -> Result err String
stringNotEmpty error str _ =
    if String.isEmpty str then
        Err error

    else
        Ok str


atLeastLength : Int -> err -> String -> FieldDict tag err -> Result err String
atLeastLength len error str _ =
    if String.length str < len then
        Err error

    else
        Ok str


validEmailPattern : Regex
validEmailPattern =
    "^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        |> Regex.fromStringWith { caseInsensitive = True, multiline = False }
        |> Maybe.withDefault Regex.never


email : err -> String -> FieldDict tag err -> Result err String
email error str _ =
    if Regex.contains validEmailPattern str then
        Ok str

    else
        Err error


alphaNumeric : err -> String -> FieldDict tag err -> Result err String
alphaNumeric error str _ =
    if String.all Char.isAlphaNum str then
        Ok str

    else
        Err error


mustBeChecked : err -> Bool -> FieldDict tag err -> Result err Bool
mustBeChecked error checked _ =
    if True == checked then
        Ok True

    else
        Err error


mustMatchField : tag -> err -> String -> FieldDict tag err -> Result err String
mustMatchField tag error str fields =
    if asString (field tag fields).value == str then
        Ok str

    else
        Err error
