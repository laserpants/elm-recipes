module App exposing (..)

import Browser exposing (Document)
import Browser.Navigation as Navigation
import Data.Session as Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Maybe.Extra as Maybe
import Page as Page exposing (Page(..), pages)
import Recipes.Router as Router exposing (Router)
import Recipes.Session.LocalStorage as LocalStorage
import Recipes.Switch.Extended as Switch exposing (RunSwitch)
import Route as Route exposing (Route(..))
import Update.Pipeline exposing (andMap, andThen, andThenIf, mapCmd, save, using, when, with)
import Update.Pipeline.Extended exposing (Run)
import Url exposing (Url)
import Url.Parser exposing (parse)


type alias Flags =
    { session : String
    , basePath : String
    }


type Msg
    = RouterMsg Router.Msg
    | PageMsg Page.Msg


type alias Model =
    { router : Router Route
    , page : Page.Model
    , session : Maybe Session
    , restrictedUrl : Maybe String
    }


setSession : Maybe Session -> Model -> ( Model, Cmd msg )
setSession session model =
    save { model | session = session }


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



--inPage : RunSwitch (Page.Info a) Model Page.Model Msg Page.Msg


inPage =
    Page.run PageMsg pages


redirect : String -> Model -> ( Model, Cmd Msg )
redirect =
    inRouter << Router.redirect


loadPage : Page -> Model -> ( Model, Cmd Msg )
loadPage page =
    inPage (always << Switch.to page {})


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init { session, basePath } url key =
    let
        router =
            Router.init (parse Route.parser) basePath key

        page =
            Page.init HomePage
    in
    save Model
        |> andMap (mapCmd RouterMsg router)
        |> andMap (mapCmd PageMsg page)
        |> andMap (save Nothing)
        |> andMap (save Nothing)
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
                            >> andThen (redirect "/login")
                        -->> andThen
                        --    (showToast
                        --        { message = "You must log in to access that page."
                        --        , color = Warning
                        --        }
                        --    )

                    else
                        doLoadPage
                )

        unlessAuthenticated doLoadPage =
            using
                (\{ session } ->
                    if Maybe.isJust session then
                        redirect "/"

                    else
                        doLoadPage
                )

        changePage =
            case maybeRoute of
                Nothing ->
                    save

                Just About ->
                    loadPage AboutPage

                Just Home ->
                    loadPage HomePage

                Just (ShowPost postId) ->
                    loadPage ShowPostPage

                Just NewPost ->
                    whenAuthenticated (loadPage NewPostPage)

                Just Login ->
                    unlessAuthenticated (loadPage LoginPage)

                Just Register ->
                    unlessAuthenticated (loadPage RegisterPage)
    in
    using
        (\{ router } ->
            when (Just Login /= router.route)
                resetRestrictedUrl
        )
        >> andThen changePage



-->> andThen (inUi Ui.closeMenu)


handleAuthResponse : Maybe Session -> Model -> ( Model, Cmd Msg )
handleAuthResponse maybeSession =
    let
        authenticated =
            Maybe.isJust maybeSession

        returnToRestrictedUrl =
            with .restrictedUrl (redirect << Maybe.withDefault "/")
    in
    setSession maybeSession
        >> andThen (LocalStorage.updateStorage Session.encoder maybeSession)
        >> andThenIf authenticated returnToRestrictedUrl


update : Msg -> Model -> ( Model, Cmd Msg )
update msg =
    case msg of
        RouterMsg routerMsg ->
            inRouter (Router.update routerMsg { onRouteChange = handleRouteChange })

        PageMsg pageMsg ->
            inPage (Switch.update pageMsg { onAuthResponse = handleAuthResponse })


subscriptions : Model -> Sub Msg
subscriptions { page } =
    Sub.batch [ Sub.map PageMsg (Page.subscriptions page) ]


view : Model -> Document Msg
view { page } =
    { title = ""
    , body =
        [ div []
            [ ul []
                [ li [] [ a [ href "/" ] [ text "Home" ] ]
                , li [] [ a [ href "/about" ] [ text "About" ] ]
                , li [] [ a [ href "/posts/new" ] [ text "New post" ] ]
                , li [] [ a [ href "/login" ] [ text "Login" ] ]
                , li [] [ a [ href "/register" ] [ text "Register" ] ]
                ]
            ]
        , div []
            [ Html.map PageMsg (Page.view page)
            ]
        ]
    }
