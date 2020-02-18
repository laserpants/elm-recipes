module App exposing (..)

import Browser exposing (Document)
import Browser.Navigation as Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page as Page exposing (Page(..), pages)
import Recipes.Router as Router exposing (Router)
import Recipes.Switch.Extended as Switch exposing (RunSwitch)
import Route as Route exposing (Route(..))
import Update.Pipeline exposing (andMap, andThen, mapCmd, save)
import Url exposing (Url)
import Url.Parser exposing (parse)


type alias Flags =
    ()


type Msg
    = RouterMsg Router.Msg
    | PageMsg Page.Msg


type alias Model =
    { router : Router Route
    , page : Page.Model
    }


inPage : RunSwitch (Page.Info a) Model Page.Model Msg Page.Msg
inPage =
    Page.run PageMsg pages


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init () url key =
    let
        router =
            Router.init (parse Route.parser) "" key

        page = 
            Page.init HomePage 
    in
    save Model
        |> andMap (mapCmd RouterMsg router)
        |> andMap (mapCmd PageMsg page)
        |> andThen (update (Router.onUrlChange RouterMsg url))


handleRouteChange : Url -> Maybe Route -> Model -> ( Model, Cmd Msg )
handleRouteChange _ maybeRoute model =
    case maybeRoute of
        Nothing ->
            save model 

        Just Home ->
            model
                |> inPage (always << Switch.to HomePage {})

        Just NewPost ->
            model
                |> inPage (always << Switch.to NewPostPage {})

        Just (ShowPost postId) ->
            model
                |> inPage (always << Switch.to ShowPostPage {})

        Just Login ->
            model
                |> inPage (always << Switch.to LoginPage {})

        Just Register ->
            model
                |> inPage (always << Switch.to RegisterPage {})

        Just About ->
            model
                |> inPage (always << Switch.to AboutPage {})


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RouterMsg routerMsg ->
            model
                |> Router.runUpdate RouterMsg routerMsg { onRouteChange = handleRouteChange }

        PageMsg pageMsg ->
            model
                |> inPage (Switch.update pageMsg {})


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
