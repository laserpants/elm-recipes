module Recipes.Router exposing (Msg(..), Router, init, onUrlChange, onUrlRequest, redirect, run, runExtended, runUpdate, update)

import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation
import Update.Pipeline exposing (addCmd, save)
import Update.Pipeline.Extended exposing (Extended, Run, andCall, lift, runStack, runStackExtended)
import Url exposing (Url)

{-| Use the Router recipe to implement URL routing in single-page applications.
-}

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
    -> Router route
    -> ( Router route, Cmd msg )
setRoute route router =
    save { router | route = route }


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
redirect href (( { basePath, key }, _ ) as router) =
    let
        cmd =
            Navigation.replaceUrl key (basePath ++ href)
    in
    router
        |> addCmd cmd


update :
    Msg
    -> { onRouteChange : Url -> Maybe route -> a }
    -> Extended (Router route) a
    -> ( Extended (Router route) a, Cmd Msg )
update msg { onRouteChange } (( { basePath, fromUrl, key }, _ ) as router) =
    case msg of
        UrlChange url ->
            let
                path =
                    String.dropLeft (String.length basePath) url.path

                route =
                    fromUrl { url | path = path }
            in
            router
                |> lift (setRoute route)
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


type alias HasRouter route a =
    { a | router : Router route }


insertAsRouterIn :
    HasRouter route a
    -> Router route
    -> ( HasRouter route a, Cmd msg )
insertAsRouterIn model router =
    save { model | router = router }


run :
    (Msg -> msg)
    -> Run (HasRouter route a) (Router route) msg Msg b
run =
    runStack .router insertAsRouterIn


runExtended :
    (Msg -> msg)
    -> Run (Extended (HasRouter route a) c) (Router route) msg Msg b
runExtended =
    runStackExtended .router insertAsRouterIn


runUpdate :
    (Msg -> msg)
    -> Msg
    -> { onRouteChange : Url -> Maybe route -> HasRouter route a -> ( HasRouter route a, Cmd msg ) }
    -> HasRouter route a
    -> ( HasRouter route a, Cmd msg )
runUpdate toMsg msg handlers =
    update msg handlers
        |> run toMsg


onUrlChange : (Msg -> msg) -> Url -> msg
onUrlChange toMsg =
    toMsg << UrlChange


onUrlRequest : (Msg -> msg) -> UrlRequest -> msg
onUrlRequest toMsg =
    toMsg << UrlRequest
