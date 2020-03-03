module Ui exposing (..)

import Bulma.Components exposing (..)
import Bulma.Elements exposing (..)
import Bulma.Modifiers exposing (..)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Maybe.Extra as Maybe
import Page
import Process
import Task
import Ui.Toast
import Update.Pipeline exposing (andAddCmd, andThen, save, using, when)
import Update.Pipeline.Extended exposing (Extended, Run, choosing, lift, runStack)


type Msg
    = ToggleMenu
    | DismissToast Int


type alias Toast =
    { id : Int
    , message : String
    , color : Color
    }


type alias Model =
    { menuIsOpen : Bool
    , toast : Maybe Toast
    , counter : Int
    }


incrementCounter : Model -> ( Model, Cmd Msg )
incrementCounter model =
    save { model | counter = model.counter + 1 }


toggleMenu : Model -> ( Model, Cmd Msg )
toggleMenu model =
    save { model | menuIsOpen = not model.menuIsOpen }


closeMenu : Model -> ( Model, Cmd Msg )
closeMenu model =
    save { model | menuIsOpen = False }


setToast : { a | message : String, color : Color } -> Model -> ( Model, Cmd Msg )
setToast { message, color } model =
    let
        toast =
            { id = model.counter
            , message = message
            , color = color
            }
    in
    save { model | toast = Just toast }


showToast : { a | message : String, color : Color } -> Model -> ( Model, Cmd Msg )
showToast toast =
    using
        (\{ counter } ->
            let
                dismissToastTask =
                    always (DismissToast counter)
            in
            setToast toast
                >> andAddCmd (Task.perform dismissToastTask (Process.sleep 4000))
                >> andThen incrementCounter
        )


showInfoToast : String -> Model -> ( Model, Cmd Msg )
showInfoToast message =
    showToast
        { message = message
        , color = Info
        }


dismissToast : Model -> ( Model, Cmd Msg )
dismissToast model =
    save { model | toast = Nothing }


type alias HasUi a =
    { a | ui : Model }


insertAsUiIn : HasUi a -> Model -> ( HasUi a, Cmd msg )
insertAsUiIn model ui =
    save { model | ui = ui }


run :
    (msg2 -> msg1)
    -> Run (HasUi a) Model msg1 msg2 b
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
            lift toggleMenu

        DismissToast dismissId ->
            choosing
                (\{ toast } ->
                    case toast of
                        Nothing ->
                            save

                        Just { id } ->
                            when (dismissId == id) (lift dismissToast)
                )


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
        [ class "sk-three-bounce" ]
        [ div [ class "sk-child sk-bounce1" ] []
        , div [ class "sk-child sk-bounce2" ] []
        , div [ class "sk-child sk-bounce3" ] []
        ]


navbar : Model -> Page.Model -> Maybe Session -> Html Msg
navbar { menuIsOpen } page maybeSession =
    let
        isAuthenticated =
            Maybe.isJust maybeSession

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
                    [ a [ class "button is-primary", href "/logout" ] [ text "Log out" ] ]
                ]

        { isHomePage, isAboutPage, isNewPostPage } =
            page
                |> Page.option
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
        ]
