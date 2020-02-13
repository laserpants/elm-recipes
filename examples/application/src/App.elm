module App exposing (..)

import AssocList as Dict
import Browser exposing (Document)
import Browser.Navigation as Navigation
import Html exposing (Html, text, span)
import Html.Attributes
import Html.Events exposing (..)
import Page.About as About
import Page.Login as Login
import Recipes.Router as Router exposing (Router)
import Recipes.Switch as Switch exposing (..)
import Update.Pipeline exposing (map, map2, andMap, andThen, mapCmd, save)
import Update.Pipeline.Extended exposing (Run)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, parse)


--switchUpdate : Switch msg1 msg2 -> Switch a1 a2 -> ( Switch a1 a2, Cmd (Switch msg1 msg2) )
--switchUpdate updates msgs models =
--switchUpdate :
--  ( AboutPageMsg -> AboutPageState -> ( AboutPageState, Cmd AboutPageMsg ), Login.Msg -> Login.Model -> ( Login.Model, Cmd Login.Msg ) ) 
--  -> (Switch AboutPageMsg Login.Msg) 
--  -> (Switch AboutPageState Login.Model) 
--  -> ( Switch AboutPageState Login.Model, Cmd (Switch AboutPageMsg Login.Msg) )
--    ( Switch y12 (Debug.todo ""), Debug.todo "" )


--switchSubscriptions : 
--    ( AboutPageMsg -> msg
--    , Login.Msg -> msg 
--    )
--    -> Switch AboutPageState Login.Model 
--    -> Sub msg

--


type alias Flags =
    ()


--type PageMsg
--    = AboutPageMsg About.Msg
--    | LoginPageMsg Login.Msg


type Page
    = NotFoundPage
    | HomePage
    | AboutPage
    | LoginPage


type Msg
    = RouterMsg Router.Msg
--    | PageMsg PageMsg
    | SwitchMsg (Switch About.Msg Login.Msg)


type Route
    = Home
    | About
    | Login


routeParser : Parser (Route -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map About (Parser.s "about")
        , Parser.map Login (Parser.s "login")
        ]


type alias Model =
    { router : Router Route
    , page : Page
    , switch : Switch About.Model Login.Model 
    }


insertAsPageIn : Model -> Page -> ( Model, Cmd msg )
insertAsPageIn model page =
    save { model | page = page }


insertAsSwitchIn : Model -> Switch About.Model Login.Model -> ( Model, Cmd msg )
insertAsSwitchIn model switch =
    save { model | switch = switch }


inRouter : Run Model (Router Route) Msg Router.Msg a
inRouter =
    Router.run RouterMsg


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init () url key =
    let
        router =
            Router.init (parse routeParser) "" key

        switch =
            save (Switch Nothing Nothing)
    in
    save Model
        |> andMap (mapCmd RouterMsg router)
        |> andMap (save HomePage)
        |> andMap (mapCmd SwitchMsg switch)
        |> andThen (update (Router.onUrlChange RouterMsg url))
        |> andThen (switchTo AboutPage)


redirect : String -> Model -> ( Model, Cmd Msg )
redirect =
    inRouter << Router.redirect


handleRouteChange : Url -> Maybe Route -> Model -> ( Model, Cmd Msg )
handleRouteChange _ maybeRoute model =
    case maybeRoute of
        Nothing ->
            save model

        Just Home ->
            save model

        Just About ->
            model
                |> switchTo AboutPage

        Just Login ->
            model
                |> switchTo LoginPage


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RouterMsg routerMsg ->
            model
                |> Router.runUpdate RouterMsg routerMsg { onRouteChange = handleRouteChange }

        SwitchMsg switchMsg ->
            model
                |> switchUpdate__ switchMsg 


xxx =
    Choice 
        { init = About.init
        , update = About.update
        , subscriptions = About.subscriptions
        , view = About.view 
        , page = AboutPage
        }

        { init = Login.init
        , update = Login.update
        , subscriptions = Login.subscriptions
        , view = Login.view 
        , page = LoginPage
        }


--yyy =
--    makePage2
--        |> addPage AboutPage 
--              {
--              }
--        |> addPage LoginPage
--              {
--              }


--yxx =
--   [ { init = \model -> About.init |> mapCmd 
--     }
--   , { init = \model -> Login.init
--     }
--   ]



switchSubscriptions__ =
    switchSubscriptions_ SwitchMsg xxx 


switchUpdate__ =
    switchUpdate_ SwitchMsg xxx 


switchView__ =
    switchView_ SwitchMsg xxx 


switchTo page model =
    switchTo_ SwitchMsg xxx page
        |> andThen (insertAsSwitchIn model)


subscriptions : Model -> Sub Msg
subscriptions { switch } =
    Sub.batch [ switchSubscriptions__ switch ]


view : Model -> Document Msg
view { page, switch } =
    { title = ""
    , body =
        [ text "Wat"
--        , Html.map SwitchMsg (switchView (Choice About.view Login.view) switch)
        , switchView__ switch
        ]
    }


--baz = Debug.todo ""
--
--faz = baz AboutPage { update = About.update }


