module Ui exposing (..)

import Bulma.Components exposing (..)
import Bulma.Elements exposing (..)
import Bulma.Modifiers exposing (..)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Maybe.Extra as Maybe
import Process
import Task
import Ui.Toast
import Update.Pipeline exposing (andAddCmd, andThen, save, using, when)
import Update.Pipeline.Extended exposing (Extended, Run, choosing, lift, runStack)


type alias Id =
    Int


type Msg
    = ToggleMenu
    | DismissToast Id
    | Logout


type alias Toast =
    { id : Id
    , message : String
    , color : Color
    }


type alias Model =
    { menuIsOpen : Bool
    , toast : Maybe Toast
    , counter : Id
    }


incrementCounter : Extended Model a -> ( Extended Model a, Cmd Msg )
incrementCounter ( model, calls ) =
    save ( { model | counter = model.counter + 1 }, calls )


toggleMenu : Extended Model a -> ( Extended Model a, Cmd msg )
toggleMenu ( model, calls ) =
    save ( { model | menuIsOpen = not model.menuIsOpen }, calls )


closeMenu : Extended Model a -> ( Extended Model a, Cmd msg )
closeMenu ( model, calls ) =
    save ( { model | menuIsOpen = False }, calls )


setToast :
    { a | message : String, color : Color }
    -> Model
    -> ( Model, Cmd Msg )
setToast { message, color } model =
    let
        toast =
            { id = model.counter
            , message = message
            , color = color
            }
    in
    save { model | toast = Just toast }


showToast :
    { a | message : String, color : Color }
    -> Extended Model b
    -> ( Extended Model b, Cmd Msg )
showToast toast =
    choosing
        (\{ counter } ->
            let
                dismissToastTask =
                    always (DismissToast counter)
            in
            lift (setToast toast)
                >> andAddCmd (Task.perform dismissToastTask (Process.sleep 4000))
                >> andThen incrementCounter
        )


showInfoToast : String -> Extended Model a -> ( Extended Model a, Cmd Msg )
showInfoToast message =
    showToast
        { message = message
        , color = Info
        }


dismissToast : Extended Model a -> ( Extended Model a, Cmd Msg )
dismissToast ( model, calls ) =
    save ( { model | toast = Nothing }, calls )


type alias HasUi a =
    { a | ui : Model }


insertAsUiIn : HasUi a -> Model -> ( HasUi a, Cmd msg )
insertAsUiIn model ui =
    save { model | ui = ui }


run : (msg2 -> msg1) -> Run (HasUi a) Model msg1 msg2 b
run =
    runStack .ui insertAsUiIn


init : ( Model, Cmd Msg )
init =
    save
        { menuIsOpen = False
        , toast = Nothing
        , counter = 1
        }


update : Msg -> Extended Model a -> ( Extended Model a, Cmd Msg )
update msg =
    case msg of
        ToggleMenu ->
            toggleMenu

        DismissToast dismissId ->
            choosing
                (\{ toast } ->
                    case toast of
                        Nothing ->
                            save

                        Just { id } ->
                            when (dismissId == id)
                                dismissToast
                )

        Logout ->
            save


toastMessage : Model -> Html Msg
toastMessage { toast } =
    case toast of
        Nothing ->
            text ""

        Just { id, message, color } ->
            let
                notification =
                    notificationWithDelete color
                        []
                        (DismissToast id)
                        [ text message
                        ]
            in
            Ui.Toast.container notification


spinner : Html msg
spinner =
    div
        [ class "sk-flow" ]
        [ div [ class "sk-flow-dot" ] []
        , div [ class "sk-flow-dot" ] []
        , div [ class "sk-flow-dot" ] []
        ]


navbar :
    { isHomePage : Bool
    , isAboutPage : Bool
    , isNewPostPage : Bool
    , isAuthenticated : Bool
    , menuIsOpen : Bool
    }
    -> Html Msg
navbar { menuIsOpen, isHomePage, isAboutPage, isNewPostPage, isAuthenticated } =
    let
        burger =
            navbarBurger menuIsOpen
                [ class "has-text-white"
                , onClick ToggleMenu
                ]
                [ span [] []
                , span [] []
                , span [] []
                ]

        buttons =
            if not isAuthenticated then
                [ p
                    [ class "control"
                    ]
                    [ a
                        [ class "button is-primary"
                        , href "/register"
                        ]
                        [ text "Register"
                        ]
                    ]
                , p
                    [ class "control"
                    ]
                    [ a
                        [ class "button is-light"
                        , href "/login"
                        ]
                        [ text "Log in"
                        ]
                    ]
                ]

            else
                [ p [ class "control" ]
                    [ Html.button
                        [ class "button is-primary"
                        , onClick Logout
                        ]
                        [ text "Log out"
                        ]
                    ]
                ]
    in
    fixedNavbar Top
        { navbarModifiers | color = Info }
        []
        [ navbarBrand []
            burger
            [ navbarItem False
                []
                [ h5 [ class "title is-5" ]
                    [ a
                        [ class "has-text-white"
                        , href "/"
                        ]
                        [ text "Facepalm" ]
                    ]
                ]
            ]
        , navbarMenu menuIsOpen
            []
            [ navbarStart [ class "is-unselectable" ]
                [ navbarItemLink isHomePage
                    [ href "/"
                    ]
                    [ text "Home"
                    ]
                , navbarItemLink isAboutPage
                    [ href "/about"
                    ]
                    [ text "About"
                    ]
                , navbarItemLink isNewPostPage
                    [ href "/posts/new"
                    ]
                    [ text "New post"
                    ]
                ]
            , navbarEnd []
                [ navbarItem False
                    []
                    [ div [ class "field is-grouped" ] buttons
                    ]
                ]
            ]
        ]
