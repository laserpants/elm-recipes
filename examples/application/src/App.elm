module App exposing (..)

import Browser exposing (Document)
import Browser.Navigation as Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Recipes.Router as Router exposing (Router)
import Update.Pipeline exposing (andMap, andThen, mapCmd, save)
import Update.Pipeline.Extended exposing (Run)
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


inRouter : Run Model (Router Route) Msg Router.Msg a
inRouter =
    Router.run RouterMsg


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init () url key =
    let
        router =
            Router.init (parse routeParser) "" key
    in
    save Model
        |> andMap (mapCmd RouterMsg router)
        |> andMap (save HomePage)
        |> andThen (update (Router.onUrlChange RouterMsg url))


redirect : String -> Model -> ( Model, Cmd Msg )
redirect =
    inRouter << Router.redirect


handleRouteChange : Url -> Maybe Route -> Model -> ( Model, Cmd Msg )
handleRouteChange _ maybeRoute model =
    case maybeRoute of
        Nothing ->
            save { model | page = NotFoundPage }

        Just Home ->
            save { model | page = HomePage }

        Just About ->
            save { model | page = AboutPage }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RouterMsg routerMsg ->
            model
                |> Router.runUpdate RouterMsg routerMsg { onRouteChange = handleRouteChange }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view { page } =
    { title = ""
    , body =
        [ text "Wat"
        ]
    }
