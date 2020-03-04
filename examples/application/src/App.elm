module App exposing (..)

import Browser exposing (Document)
import Browser.Navigation as Navigation
import Bulma.Layout exposing (SectionSpacing(..))
import Bulma.Modifiers exposing (..)
import Data.Comment exposing (Comment)
import Data.Post exposing (Post)
import Data.Session as Session exposing (Session)
import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Maybe.Extra as Maybe
import Page as Page exposing (Pages, index, pages)
import Recipes.Router as Router exposing (Router)
import Recipes.Session.LocalStorage as LocalStorage exposing (setSession)
import Recipes.Switch.Extended as Switch exposing (RunSwitch)
import Route as Route exposing (Route(..))
import Ui
import Ui.Page
import Update.Pipeline exposing (andMap, andThen, andThenIf, mapCmd, save, using, when, with)
import Update.Pipeline.Extended exposing (Run, lift, runStack)
import Url exposing (Url)
import Url.Parser exposing (parse)


type alias Flags =
    { session : String
    , basePath : String
    }


type Msg
    = RouterMsg Router.Msg
    | PageMsg Page.Msg
    | UiMsg Ui.Msg
    | Logout


type alias Model =
    { router : Router Route
    , page : Page.Model
    , session : Maybe Session
    , restrictedUrl : Maybe String
    , ui : Ui.Model
    }


setRestrictedUrl : Url -> Model -> ( Model, Cmd msg )
setRestrictedUrl { path } model =
    let
        url =
            String.dropLeft (String.length model.router.basePath) path
    in
    save { model | restrictedUrl = Just url }


resetRestrictedUrl : Model -> ( Model, Cmd msg )
resetRestrictedUrl model =
    save { model | restrictedUrl = Nothing }


inRouter : Run Model (Router Route) Msg Router.Msg a
inRouter =
    Router.run RouterMsg


inPage : RunSwitch (Pages a) Model Page.Model Msg Page.Msg
inPage =
    Page.run PageMsg pages


inUi : Run Model Ui.Model Msg Ui.Msg a
inUi =
    Ui.run UiMsg


redirectTo : String -> Model -> ( Model, Cmd Msg )
redirectTo =
    inRouter << Router.redirect


returnToRestrictedUrl : Model -> ( Model, Cmd Msg )
returnToRestrictedUrl =
    with .restrictedUrl
        (Maybe.withDefault "/" >> redirectTo)


showToast :
    { a
        | message : String
        , color : Color
    }
    -> Model
    -> ( Model, Cmd Msg )
showToast =
    inUi << Ui.showToast



--loadPage :
--    (Pages a -> Info arg Page.Model Page.Msg m msg h a)
--    -> arg
--    -> Model
--    -> ( Model, Cmd Msg )


loadPage page =
    inPage << Switch.to page


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init { session, basePath } url key =
    let
        router =
            Router.init (parse Route.parser) basePath key

        page =
            save Switch.initial

        ui =
            Ui.init
    in
    save Model
        |> andMap (mapCmd RouterMsg router)
        |> andMap (mapCmd PageMsg page)
        |> andMap (save Nothing)
        |> andMap (save Nothing)
        |> andMap (mapCmd UiMsg ui)
        |> andThen (update (Router.onUrlChange RouterMsg url))


handleRouteChange : Url -> Maybe Route -> Model -> ( Model, Cmd Msg )
handleRouteChange url maybeRoute =
    let
        whenAuthenticated doLoadPage =
            using
                (\{ session } ->
                    if Nothing == session then
                        -- Set URL to redirect back to after successful login
                        setRestrictedUrl url
                            >> andThen (redirectTo "/login")
                            >> andThen
                                (showToast
                                    { message = "You must log in to access that page."
                                    , color = Warning
                                    }
                                )

                    else
                        doLoadPage
                )

        unlessAuthenticated doLoadPage =
            using
                (\{ session } ->
                    if Maybe.isJust session then
                        redirectTo "/"

                    else
                        doLoadPage
                )

        changePage =
            let
                { notFoundPage, homePage, newPostPage, showPostPage, loginPage, registerPage, aboutPage } =
                    index
            in
            case maybeRoute of
                Nothing ->
                    loadPage notFoundPage ()

                Just About ->
                    loadPage aboutPage ()

                Just Home ->
                    loadPage homePage ()

                Just (ShowPost postId) ->
                    loadPage showPostPage postId

                Just NewPost ->
                    whenAuthenticated (loadPage newPostPage ())

                Just Login ->
                    unlessAuthenticated (loadPage loginPage ())

                Just Register ->
                    unlessAuthenticated (loadPage registerPage ())
    in
    using
        (\{ router } ->
            when (Just Login /= router.route)
                resetRestrictedUrl
        )
        >> andThen changePage
        >> andThen (inUi Ui.closeMenu)


handleAuthResponse : Maybe Session -> Model -> ( Model, Cmd Msg )
handleAuthResponse maybeSession =
    let
        isAuthenticated =
            Maybe.isJust maybeSession
    in
    setSession maybeSession
        >> andThen (LocalStorage.updateStorage Session.encoder maybeSession)
        >> andThenIf isAuthenticated returnToRestrictedUrl


handlePostAdded : Post -> Model -> ( Model, Cmd Msg )
handlePostAdded _ =
    redirectTo "/"
        >> andThen
            (showToast
                { message = "Your post was published."
                , color = Info
                }
            )


handleCommentCreated : Comment -> Model -> ( Model, Cmd Msg )
handleCommentCreated _ =
    showToast
        { message = "Thank you for your comment."
        , color = Info
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg =
    case msg of
        RouterMsg routerMsg ->
            let
                handlers =
                    { onRouteChange = handleRouteChange }
            in
            inRouter (Router.update routerMsg handlers)

        PageMsg pageMsg ->
            let
                handlers =
                    { onAuthResponse = handleAuthResponse
                    , onPostAdded = handlePostAdded
                    , onCommentCreated = handleCommentCreated
                    , onRegistrationComplete = always (redirectTo "/login")
                    }
            in
            inPage (Switch.update pageMsg handlers)

        UiMsg uiMsg ->
            inUi (Ui.update uiMsg)

        Logout ->
            setSession Nothing
                >> andThen LocalStorage.clearStorage
                >> andThen (redirectTo "/")
                >> andThen
                    (showToast
                        { message = "You have been logged out."
                        , color = Info
                        }
                    )


subscriptions : Model -> Sub Msg
subscriptions { page } =
    Sub.batch [ Sub.map PageMsg (Page.subscriptions page) ]


view : Model -> Document Msg
view { page, session, ui } =
    { title = "Welcome to Facepalm"
    , body =
        [ div [] [] -- toast
        , Bulma.Layout.section NotSpaced
            []
            [ Html.map UiMsg (Ui.navbar ui page session)
            , Html.map PageMsg (Page.view page)
            ]
        ]
    }
