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
import Recipes.Switch as Switch exposing (Item1, Item2, Layout2, OneOf2, RunSwitch, label2, layout2)
import Update.Pipeline exposing (andMap, andThen, map, map2, mapCmd, save)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, parse)


type alias Flags =
    ()


type alias Labels a1 a2 =
    { aboutPage : a1
    , loginPage : a2
    }


type Page
    = AboutPage
    | LoginPage


type Msg
    = SwitchMsg (OneOf2 About.Msg Login.Msg)
    | Goto Page


type alias Model =
    { switch : OneOf2 About.Model Login.Model
    }


type alias Pages =
    Layout2 About.Model About.Msg {} Login.Model Login.Msg {}


pages : Pages
pages =
    layout2
        { init = About.init
        , update = About.update
        , subscriptions = About.subscriptions
        , view = About.view
        }
        { init = Login.init
        , update = Login.update
        , subscriptions = Login.subscriptions
        , view = Login.view
        }


switchSubscriptions : OneOf2 About.Model Login.Model -> Sub Msg
switchSubscriptions =
    Sub.map SwitchMsg << Switch.subscriptions pages


switchView : OneOf2 About.Model Login.Model -> Html Msg
switchView =
    Html.map SwitchMsg << Switch.view pages


inSwitch : RunSwitch Pages Model (OneOf2 About.Model Login.Model) Msg (OneOf2 About.Msg Login.Msg)
inSwitch =
    Switch.run SwitchMsg pages


init : Flags -> ( Model, Cmd Msg )
init () =
    let
        switch =
            let
                { aboutPage } =
                    label2 Labels
            in
            Switch.init aboutPage {} pages
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
                |> inSwitch (Switch.update switchMsg)

        Goto page ->
            let
                { aboutPage, loginPage } =
                    label2 Labels
            in
            case page of
                AboutPage ->
                    model
                        |> inSwitch (Switch.to aboutPage {})

                LoginPage ->
                    model
                        |> inSwitch (Switch.to loginPage {})


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
