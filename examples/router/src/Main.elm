module Main exposing (..)

import Browser exposing (Document, UrlRequest, application)
import Browser.Navigation as Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Update.Router as Router exposing (Router, forceUrlChange, handleUrlChange, handleUrlRequest)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, parse)


type alias Flags =
    ()


type Msg
    = RouterMsg Router.Msg


type Page
    = NotFoundPage
    | HomePage
    | AboutPage


type Route
    = Home
    | About


routeParser : Parser (Route -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map About (Parser.s "about")
        ]


type alias Model =
    { router : Router Route
    , page : Page
    }


inRouter : Router.Bundle Route Model Msg -> Model -> ( Model, Cmd Msg )
inRouter =
    Router.run RouterMsg


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init () url key =
    let
        ( router, routerMsg ) =
            Router.initMap RouterMsg (parse routeParser) "" key

        ( model, cmd ) =
            { router = router
            , page = HomePage
            }
                |> inRouter (forceUrlChange url { onRouteChange = handleRouteChange })
    in
    ( model, Cmd.batch [ cmd, routerMsg ] )


handleRouteChange : Url -> Maybe Route -> Model -> ( Model, Cmd Msg )
handleRouteChange url maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFoundPage }, Cmd.none )

        Just Home ->
            ( { model | page = HomePage }, Cmd.none )

        Just About ->
            ( { model | page = AboutPage }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RouterMsg routerMsg ->
            let
                updateRouter =
                    Router.update routerMsg
                        { onRouteChange = handleRouteChange }
            in
            inRouter updateRouter model


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view { page } =
    { title = ""
    , body =
        [ div []
            [ ul []
                [ li [] [ a [ href "/" ] [ text "Home" ] ]
                , li [] [ a [ href "/about" ] [ text "About" ] ]
                , li [] [ a [ href "/missing" ] [ text "Win a dinosaur" ] ]
                ]
            ]
        , div []
            [ case page of
                HomePage ->
                    text "Home"

                AboutPage ->
                    text "About"

                NotFoundPage ->
                    text "404 Not Found"
            ]
        ]
    }


main : Program Flags Model Msg
main =
    application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlChange = handleUrlChange RouterMsg
        , onUrlRequest = handleUrlRequest RouterMsg
        }
