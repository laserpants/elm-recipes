module Main exposing (..)

import Browser exposing (Document, document)
import Html exposing (a, div, text)
import Html.Attributes exposing (class, href, placeholder, style, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Json
import Json.Encode as Encode
import Recipes.WebSocket as WebSocket
import Update.Pipeline exposing (andMap, andThen, save, when)


wsMessageEncoder : { a | query : String } -> Json.Value
wsMessageEncoder { query } =
    Encode.object
        [ ( "query", Encode.string query )
        ]


type alias WsResponse =
    { query : String
    , suggestions : List String
    }


wsResponseDecoder : Json.Decoder WsResponse
wsResponseDecoder =
    Json.map2 WsResponse
        (Json.field "query" Json.string)
        (Json.field "suggestions" (Json.list Json.string))


type Msg
    = OnInput String
    | WebSocketMsg (Result WebSocket.Error Msg)
    | WsReponseMsg WsResponse
    | WsError WebSocket.Error
    | Select String


type Status
    = Stopped
    | Searching
    | HasResults


type alias Model =
    { websocket : WebSocket.MessageHandler Msg
    , input : String
    , suggestions : List String
    , status : Status
    }


setInput : String -> Model -> ( Model, Cmd Msg )
setInput input model =
    save { model | input = input }


setSuggestions : List String -> Model -> ( Model, Cmd Msg )
setSuggestions suggestions model =
    save { model | suggestions = suggestions }


setStatus : Status -> Model -> ( Model, Cmd Msg )
setStatus status model =
    save { model | status = status }


init : () -> ( Model, Cmd Msg )
init () =
    let
        websocket =
            WebSocket.init
                |> andThen
                    (WebSocket.createHandler WsReponseMsg "suggestions" wsResponseDecoder)
    in
    save Model
        |> andMap websocket
        |> andMap (save "")
        |> andMap (save [])
        |> andMap (save Stopped)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WebSocketMsg ws ->
            model
                |> WebSocket.updateModel (Just WsError) update ws

        WsReponseMsg { query, suggestions } ->
            model
                |> when (model.input == query)
                    (setSuggestions suggestions
                        >> andThen (setStatus HasResults)
                    )

        WsError error ->
            case error of
                WebSocket.UnknownMessageType message ->
                    model
                        |> save
                        |> Debug.log ("Websocket: Ignoring unknown message type `" ++ message ++ "`.")

                WebSocket.JsonError jsonError ->
                    model
                        |> save
                        |> Debug.log ("Websocket JSON error: " ++ Debug.toString jsonError)

        OnInput input ->
            if "" == input then
                model
                    |> setInput ""
                    |> andThen (setStatus Stopped)

            else
                let
                    encodedMsg =
                        wsMessageEncoder { query = input }
                in
                model
                    |> setInput input
                    |> andThen (WebSocket.sendMessage "search" encodedMsg)
                    |> andThen (setStatus Searching)

        Select string ->
            model
                |> setInput string
                |> andThen (setStatus Stopped)


subscriptions : Model -> Sub Msg
subscriptions { websocket } =
    Sub.map WebSocketMsg (WebSocket.subscriptions websocket)


view : Model -> Document Msg
view { input, suggestions, status } =
    { title = "Websocket recipe example"
    , body =
        [ div
            [ class "wrapper"
            ]
            [ Html.input
                [ onInput OnInput
                , value input
                , placeholder "Type the name of a state in the U.S."
                ]
                []
            , case status of
                Stopped ->
                    text ""

                Searching ->
                    div
                        [ style "flex" "1"
                        ]
                        [ text "..."
                        ]

                HasResults ->
                    let
                        item res =
                            a
                                [ href "#"
                                , onClick (Select res)
                                ]
                                [ div [ class "result" ] [ text res ] ]
                    in
                    if List.isEmpty suggestions then
                        div [ class "no-results" ] [ text "No results" ]

                    else
                        div [] (List.map item suggestions)
            ]
        ]
    }


main : Program () Model Msg
main =
    document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
