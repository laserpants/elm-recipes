module Recipes.Router exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation
import Update.Pipeline exposing (addCmd, andThen, mapCmd, save)
import Update.Pipeline.Extended exposing (Extended, Stack, andCall, mapM, runStack)
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


type alias ExtendedRouter route a =
    Extended (Router route) a


redirect :
    String
    -> ExtendedRouter route a
    -> ( ExtendedRouter route a, Cmd Msg )
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
    -> ExtendedRouter route a
    -> ( ExtendedRouter route a, Cmd Msg )
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
                |> mapM (setRoute route)
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


type alias Run model route msg c =
    Stack model (Router route) msg Msg c -> model -> ( model, Cmd msg )


type alias Parent a route =
    { a | router : Router route }


run : (Msg -> msg) -> Run (Parent a route) route msg c
run =
    runStack .router (\model router -> save { model | router = router })


runUpdate :
    (Msg -> msg)
    -> Msg
    -> { onRouteChange : Url -> Maybe route -> Parent a route -> ( Parent a route, Cmd msg ) }
    -> Parent a route
    -> ( Parent a route, Cmd msg )
runUpdate toMsg msg handlers =
    update msg handlers
        |> run toMsg


onUrlChange : (Msg -> msg) -> Url -> msg
onUrlChange toMsg =
    toMsg << UrlChange


onUrlRequest : (Msg -> msg) -> UrlRequest -> msg
onUrlRequest toMsg =
    toMsg << UrlRequest
