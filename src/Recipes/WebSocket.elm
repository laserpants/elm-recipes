module Recipes.WebSocket exposing (..)

import Dict exposing (Dict)
import Json.Decode as Json exposing (decodeString, field)
import Json.Encode as Encode
import Update.Pipeline exposing (addCmd, andMap, save)
import Recipes.WebSocket.Ports as Ports


type Error
    = UnknownMessageType String
    | JsonError Json.Error


type alias MessageHandler msg =
    { parsers : Dict String (Json.Decoder msg)
    }


handler :
    String
    -> (a -> msg)
    -> Json.Decoder a
    -> ( String, Json.Decoder msg )
handler key toMsg decoder =
    ( key
    , decoder
        |> Json.field "payload"
        |> Json.andThen (toMsg >> Json.succeed)
    )


addHandler :
    (a -> msg)
    -> String
    -> Json.Decoder a
    -> List ( String, Json.Decoder msg )
    -> List ( String, Json.Decoder msg )
addHandler toMsg key =
    (::) << handler key toMsg


init : List ( String, Json.Decoder msg ) -> ( MessageHandler msg, Cmd msg )
init parsers =
    save MessageHandler
        |> andMap (save (Dict.fromList parsers))


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
    (msg -> a -> ( a, Cmd msg ))
    -> Result Error msg
    -> a
    -> ( a, Cmd msg )
updateModel update result =
    case result of
        Err error ->
            case error of
                UnknownMessageType message ->
                    save
                        |> Debug.log ("Websocket: Ignoring unknown message type `" ++ message ++ "`.")

                JsonError jsonError ->
                    save
                        |> Debug.log ("Websocket JSON error: " ++ Debug.toString jsonError)

        Ok msg ->
            update msg


updateExtendedModel :
    (msg -> b -> a -> ( a, Cmd msg ))
    -> b
    -> Result Error msg
    -> a
    -> ( a, Cmd msg )
updateExtendedModel update callbacks =
    updateModel (\msg -> update msg callbacks)
