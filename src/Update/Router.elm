module Update.Router exposing (Msg(..), Router, Run, forceUrlChange, handleUrlChange, handleUrlRequest, init, initMap, redirect, run, runCustom, update)

import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation
import Update.Pipeline exposing (..)
import Url exposing (Url)


withCalls : List c -> ( a, Cmd msg ) -> ( a, Cmd msg, List c )
withCalls funs ( model, cmd ) =
    ( model, cmd, funs )


type Msg
    = UrlChange Url
    | UrlRequest UrlRequest


type alias Router route =
    { route : Maybe route
    , key : Navigation.Key
    , fromUrl : Url -> Maybe route
    , basePath : String
    }


setRoute : Maybe route -> Router route -> ( Router route, Cmd msg )
setRoute route router =
    save { router | route = route }


type alias Run route model msg =
    (Router route -> ( Router route, Cmd Msg, List (model -> ( model, Cmd msg )) ))
    -> model
    -> ( model, Cmd msg )


runCustom :
    (model -> Router route)
    -> (Router route -> model -> model)
    -> (Msg -> msg)
    -> Run route model msg
runCustom get set toMsg updater model =
    let
        ( router, cmd, calls ) =
            updater (get model)
    in
    set router model
        |> sequence calls
        |> andAddCmd (Cmd.map toMsg cmd)


run : (Msg -> msg) -> Run route { a | router : Router route } msg
run =
    let
        setRouter router model =
            { model | router = router }
    in
    runCustom .router setRouter


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


initMap :
    (Msg -> msg)
    -> (Url -> Maybe route)
    -> String
    -> Navigation.Key
    -> ( Router route, Cmd msg )
initMap toMsg fromUrl basePath key =
    init fromUrl basePath key
        |> mapCmd toMsg


redirect : String -> Router route -> ( Router route, Cmd Msg, List a )
redirect href router =
    let
        { basePath, key } =
            router

        redirectCmd =
            Navigation.replaceUrl key (basePath ++ href)
    in
    router
        |> addCmd redirectCmd
        |> withCalls []


forceUrlChange :
    Url
    -> { onRouteChange : Url -> Maybe route -> a }
    -> Router route
    -> ( Router route, Cmd Msg, List a )
forceUrlChange =
    update << UrlChange


handleUrlChange : (Msg -> msg) -> Url -> msg
handleUrlChange =
    (>>) UrlChange


handleUrlRequest : (Msg -> msg) -> UrlRequest -> msg
handleUrlRequest =
    (>>) UrlRequest


update :
    Msg
    -> { onRouteChange : Url -> Maybe route -> a }
    -> Router route
    -> ( Router route, Cmd Msg, List a )
update msg { onRouteChange } router =
    let
        { basePath, fromUrl, key } =
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
                |> withCalls [ onRouteChange url route ]

        UrlRequest (Browser.Internal url) ->
            let
                urlStr =
                    Url.toString { url | path = basePath ++ url.path }
            in
            router
                |> addCmd (Navigation.pushUrl key urlStr)
                |> withCalls []

        UrlRequest (Browser.External "") ->
            withCalls [] (save router)

        UrlRequest (Browser.External href) ->
            router
                |> addCmd (Navigation.load href)
                |> withCalls []
