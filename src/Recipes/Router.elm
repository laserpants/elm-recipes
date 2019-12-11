module Recipes.Router exposing (Msg(..), Router, forceUrlChange, init, redirect, run, update, urlChangeMsg, urlRequestMsg)

import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation
import Recipes.Helpers exposing (Bundle, andCall, runBundle)
import Update.Pipeline exposing (addCmd, save)
import Url exposing (Url)


type Msg
    = UrlChange Url
    | UrlRequest UrlRequest


type alias Router route =
    { route : Maybe route
    , key : Navigation.Key
    , fromUrl : Url -> Maybe route
    , basePath : String
    }


setRoute : Maybe route -> ( Router route, List a ) -> ( ( Router route, List a ), Cmd msg )
setRoute route ( router, calls ) =
    save ( { router | route = route }, calls )


run :
    (Msg -> msg)
    -> Bundle (Router route) Msg { a | router : Router route } msg
    -> { a | router : Router route }
    -> ( { a | router : Router route }, Cmd msg )
run =
    let
        setRouter router model =
            { model | router = router }
    in
    runBundle .router setRouter


init :
    (Url -> Maybe route)
    -> String
    -> Navigation.Key
    -> ( Router route, Cmd Msg )
init fromUrl basePath key =
    save
        { route = Nothing
        , key = key
        , fromUrl = fromUrl
        , basePath = basePath
        }


redirect : String -> Router route -> ( ( Router route, List a ), Cmd Msg )
redirect href router =
    let
        { basePath, key } =
            router

        redirectCmd =
            Navigation.replaceUrl key (basePath ++ href)
    in
    ( router, [] )
        |> addCmd redirectCmd


forceUrlChange :
    Url
    -> { onRouteChange : Url -> Maybe route -> a }
    -> Router route
    -> ( ( Router route, List a ), Cmd Msg )
forceUrlChange =
    update << UrlChange


update :
    Msg
    -> { onRouteChange : Url -> Maybe route -> a }
    -> Router route
    -> ( ( Router route, List a ), Cmd Msg )
update msg { onRouteChange } ({ basePath, fromUrl, key } as router) =
    case msg of
        UrlChange url ->
            let
                path =
                    String.dropLeft (String.length basePath) url.path

                route =
                    fromUrl { url | path = path }
            in
            ( router, [] )
                |> setRoute route
                |> andCall (onRouteChange url route)

        UrlRequest (Browser.Internal url) ->
            let
                urlStr =
                    Url.toString { url | path = basePath ++ url.path }
            in
            ( router, [] )
                |> addCmd (Navigation.pushUrl key urlStr)

        UrlRequest (Browser.External "") ->
            ( router, [] )
                |> save

        UrlRequest (Browser.External href) ->
            ( router, [] )
                |> addCmd (Navigation.load href)


urlChangeMsg : (Msg -> msg) -> Url -> msg
urlChangeMsg toMsg =
    toMsg << UrlChange


urlRequestMsg : (Msg -> msg) -> UrlRequest -> msg
urlRequestMsg toMsg =
    toMsg << UrlRequest
