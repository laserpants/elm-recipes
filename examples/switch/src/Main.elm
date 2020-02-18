module Main exposing (..)

import AssocList as Dict
import Browser exposing (Document, document)
import Browser.Navigation as Navigation
import Html exposing (Html, button, div, span, text)
import Html.Attributes
import Html.Events exposing (..)
import Maybe.Extra as Maybe
import Page.About as About
import Page.Login as Login
import Recipes.Switch.Extended as Switch exposing (OneOf2, RunSwitch)
import Update.Pipeline exposing (andMap, andThen, map, map2, mapCmd, save)
import Update.Pipeline.Extended exposing (Extended, Run, extend, lift)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, parse)


type alias Flags =
    ()


type Page
    = NotFoundPage
    | HomePage
    | AboutPage
    | LoginPage


type Msg
    = SwitchMsg (OneOf2 About.Msg Login.Msg)
    | Goto Page


type alias Model =
    { switch : OneOf2 About.Model Login.Model
    }


type alias PageInfo a =
    Switch.Layout2 Page { onSomething : Int -> a } About.Model About.Msg Login.Model Login.Msg a


pages : PageInfo a
pages =
    let
        aboutPage =
            { init = About.init
            , update = About.update
            , subscriptions = About.subscriptions
            , view = About.view
            }

        loginPage =
            { init = Login.init
            , update = Login.update
            , subscriptions = Login.subscriptions
            , view = Login.view
            }
    in
    Switch.layout2
        ( AboutPage, aboutPage )
        ( LoginPage, loginPage )


switchSubscriptions : OneOf2 About.Model Login.Model -> Sub Msg
switchSubscriptions =
    Sub.map SwitchMsg << Switch.subscriptions pages


switchView : OneOf2 About.Model Login.Model -> Html Msg
switchView =
    Html.map SwitchMsg << Switch.view pages


inSwitch : RunSwitch (PageInfo a) Model (OneOf2 About.Model Login.Model) Msg (OneOf2 About.Msg Login.Msg)
inSwitch =
    Switch.run SwitchMsg pages


init : Flags -> ( Model, Cmd Msg )
init () =
    let
        switch =
            pages
                |> Switch.init AboutPage {}
    in
    save Model
        |> andMap (mapCmd SwitchMsg switch)


handleSomething : Int -> Model -> ( Model, Cmd Msg )
handleSomething _ =
    save


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SwitchMsg switchMsg ->
            model
                |> inSwitch
                    (Switch.update switchMsg
                        { onSomething = handleSomething }
                    )

        Goto page ->
            model
                |> inSwitch (always << Switch.to page {})


subscriptions : Model -> Sub Msg
subscriptions { switch } =
    Sub.batch [ switchSubscriptions switch ]


view : Model -> Document Msg
view { switch } =
    { title = ""
    , body =
        [ switchView switch
        , div
            []
            [ button
                [ onClick (Goto AboutPage) ]
                [ text "About" ]
            ]
        , div
            []
            [ button
                [ onClick (Goto LoginPage) ]
                [ text "Login" ]
            ]
        ]
    }


main : Program Flags Model Msg
main =
    document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
