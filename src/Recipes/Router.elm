module Recipes.Router exposing (Msg(..), Router, forceUrlChange, init, redirect, run, update, urlChangeMsg, urlRequestMsg)

import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation
import Recipes.Helpers exposing (Bundle, Extended, andCall, runBundle, mapExtended)
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


setRoute :
    Maybe route
    -> Extended (Router route) a
    -> ( Extended (Router route) a, Cmd msg )
setRoute route =
    save << mapExtended (\router -> { router | route = route })


run :
    (msg1 -> msg)
    -> Bundle { c | router : a } a msg msg1
    -> { c | router : a }
    -> ( { c | router : a }, Cmd msg )
run =
    runBundle
        (\model -> ( model.router, [] ))
        (\router model -> { model | router = router })


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


redirect : 
    String 
    -> Extended (Router route) a 
    -> ( Extended (Router route) a, Cmd Msg )
redirect href router =
    let
        ( { basePath, key }, _ ) =
            router

        redirectCmd =
            Navigation.replaceUrl key (basePath ++ href)
    in
    router
        |> addCmd redirectCmd


forceUrlChange :
    Url
    -> (Url -> Maybe route -> a)
    -> Extended (Router route) a
    -> ( Extended (Router route) a, Cmd Msg )
forceUrlChange url handleUrlChange =
    update (UrlChange url) { onRouteChange = handleUrlChange }


update :
    Msg
    -> { onRouteChange : Url -> Maybe route -> a }
    -> Extended (Router route) a
    -> ( Extended (Router route) a, Cmd msg )
update msg { onRouteChange } router =
    let
        ( { basePath, fromUrl, key }, _ ) =
            router
    in
    case msg of
        UrlChange url ->
            let
                path =
                    String.dropLeft (String.length basePath) url.path

                route =
                    fromUrl { url | path = path }
            in
            router
                |> setRoute route
                |> andCall (onRouteChange url route)

        UrlRequest (Browser.Internal url) ->
            let
                urlStr =
                    Url.toString { url | path = basePath ++ url.path }
            in
            router
                |> addCmd (Navigation.pushUrl key urlStr)

        UrlRequest (Browser.External "") ->
            router
                |> save

        UrlRequest (Browser.External href) ->
            router
                |> addCmd (Navigation.load href)


urlChangeMsg : (Msg -> msg) -> Url -> msg
urlChangeMsg toMsg =
    toMsg << UrlChange


urlRequestMsg : (Msg -> msg) -> UrlRequest -> msg
urlRequestMsg toMsg =
    toMsg << UrlRequest
