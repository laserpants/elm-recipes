module Recipes.WebSocket exposing (Error(..), MessageHandler, createHandler, init, sendMessage, subscriptions, updateModel, updateModelExtended)

import Dict exposing (Dict)
import Json.Decode as Json exposing (decodeString, field)
import Json.Encode as Encode
import Recipes.WebSocket.Ports as Ports
import Update.Pipeline exposing (addCmd, andMap, save)


type Error
    = UnknownMessageType String
    | JsonError Json.Error


type alias MessageHandler msg =
    { parsers : Dict String (Json.Decoder msg)
    }


addParser :
    String
    -> Json.Decoder msg
    -> MessageHandler msg
    -> ( MessageHandler msg, Cmd msg )
addParser key decoder model =
    save { model | parsers = Dict.insert key decoder model.parsers }


createHandler :
    (a -> msg)
    -> String
    -> Json.Decoder a
    -> MessageHandler msg
    -> ( MessageHandler msg, Cmd msg )
createHandler toMsg key decoder =
    let
        handler =
            decoder
                |> Json.field "payload"
                |> Json.andThen (toMsg >> Json.succeed)
    in
    addParser key handler


init : ( MessageHandler msg, Cmd msg )
init =
    save MessageHandler
        |> andMap (save Dict.empty)


sendMessage : String -> Json.Value -> m -> ( m, Cmd msg )
sendMessage type_ payload =
    let
        envelope =
            Encode.object
                [ ( "type", Encode.string type_ )
                , ( "payload", payload )
                ]

        encodedMessage =
            Encode.encode 0 envelope
    in
    addCmd (Ports.websocketOut encodedMessage)


run : Dict String (Json.Decoder msg) -> String -> Result Error msg
run parsers str =
    let
        decoder =
            Json.field "type" Json.string
    in
    case decodeString decoder str of
        Ok atom ->
            case Dict.get atom parsers of
                Just parser ->
                    Result.mapError JsonError (decodeString parser str)

                Nothing ->
                    Err (UnknownMessageType atom)

        Err error ->
            Err (JsonError error)


subscriptions : MessageHandler msg -> Sub (Result Error msg)
subscriptions { parsers } =
    Ports.websocketIn (run parsers)


updateModel :
    Maybe (Error -> msg)
    -> (msg -> a -> ( a, Cmd msg ))
    -> Result Error msg
    -> a
    -> ( a, Cmd msg )
updateModel maybeToError update result =
    case result of
        Err error ->
            case maybeToError of
                Just toErrorMsg ->
                    update (toErrorMsg error)

                Nothing ->
                    save

        Ok msg ->
            update msg


updateModelExtended :
    Maybe (Error -> msg)
    -> (msg -> b -> a -> ( a, Cmd msg ))
    -> b
    -> Result Error msg
    -> a
    -> ( a, Cmd msg )
updateModelExtended maybeToError update callbacks =
    updateModel maybeToError (\msg -> update msg callbacks)
