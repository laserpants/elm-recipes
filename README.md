# Elm Recipes

## About

## How to use

### A note about pipelines

The [`elm-update-pipeline`](https://package.elm-lang.org/packages/laserpants/elm-update-pipeline/latest/) library is used in the implementation of this package, as well as in many of the following examples.
It is based on monadic style of programming, and a common pattern is to use the pipe operator, together with `andThen`, to chain updates together:

```elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SomeMsg someMsg ->
            save model
                |> andThen (setPower 100)
                |> andAddCmd someCmd
```

The `save` function turns a `model` value into a `( model, Cmd msg )` pair without adding any commands, 
and it is used with `andThen`, which extracts the model from a result and passes it as input to the next function in a pipeline.
The latter is like the bind (`>>=`) operator in Haskell, whereas `save` corresponds to `pure` (or `return`).

Together, these satisfy the monad laws;

```elm
{- Left identity -}  
save >> andThen f  <==>  f

{- Right identity -} 
f >> andThen save  <==>  f

{- Associativity -}  
(f >> andThen g) >> andThen h  <==>  f >> andThen (g >> andThen h)
```

&hellip; where we have types:

```elm
f : a -> ( b, Cmd msg )
g : b -> ( c, Cmd msg )
h : c -> ( d, Cmd msg )
```

Similarly, the [applicative](https://wiki.haskell.org/Applicative_functor) pattern and `andMap` from the same library are used throughout the examples to implement the `init` function:

```elm
init : Flags -> ( Model, Cmd Msg )
init flags =
    save Model
        |> andMap (save False)
        |> andMap (initSession flags)
        |> andMap initRouter
```

Note however that none of this is required for using `elm-recipes`, and I have tried to present code examples also using a more conventional approach.

### Callbacks

Another idea that 

### Examples

See `examples/application` for an example of many of these recipes used together.

## Recipes

### Api

> Use the Api recipe for lifecycle management of resources that are available to your application via Restful web services.

Here is how to use this recipe in your program:

1. Import the `Recipes.Api` module:

        import Recipes.Api as Api

2. Create a data type that represents the server resource.

        type alias MyResource =
            { ...
            }

   In the following steps, we will use the name `MyResource` to refer to this type. It is usually better to place this record in a separate module, e.g., `Data.MyResource`.

3. Add a constructor to your `Msg` type with a single field of type `Api.Msg MyResource`: 

        type Msg
            = ...
            | ApiMsg (Api.Msg MyResource)

   (I am using the name `ApiMsg` here, but you can choose anything you like.)

4. Add an `api` field to your `Model`. It should have the type `Api.Model MyResource`:

        type alias Model =
            { ...
            , api : Api.Model MyResource
            }

   If you name this field to ...

5. init

        init flags =
            let
                ( apiModel, _ ) =
                    Api.init
                        { endpoint = "/books/1"
                        , method = HttpGet
                        , expect = ...
                        , headers = []
                        }
            in
            ( { api = apiModel 
              , ...
              }
            , Cmd.batch [ ... ] )

    or using [`elm-update-pipeline`](https://package.elm-lang.org/packages/laserpants/elm-update-pipeline/latest/):

        init flags =
            let
                api =
                    Api.init
                        { endpoint = "/books/1"
                        , method = HttpGet
                        , expect = ...
                        , headers = []
                        }
            in
            save Model
                |> andMap api
                |> andMap ...



6. In your `update` function, add a case for the `Msg` constructor introduced in step three:

        update msg model =
            case msg of
                ApiMsg apiMsg ->
                    model
                        |> Api.runUpdate ApiMsg apiMsg apiDefaultHandlers

                ...

   The `apiDefaultHandlers` argument is explained 

7. Implement your view to respond to the different stages of the request:

   * `NotRequested`
   * `Requested`
   * `Available MyResource`
   * `Error Http.Error`

   For example;

          view { api } =
              case api.resource of
                  Api.NotRequested ->
                      ...

                  Api.Requested ->
                      ...

                  Api.Available myResource ->
                      ...

                  Api.Error error ->
                      ...

#### Example

```
GET /posts/1
```

```json
{
    "book": {
        "id": 1,
        "title": "Moby Dick",
        "author": "Herman Melville",
        "synopsis": "Sailor Ishmael's narrative of the obsessive quest of Ahab, captain of the whaling ship Pequod, for revenge on Moby Dick, the giant white sperm whale that on the ship's previous voyage bit off Ahab's leg at the knee."
    }
}
```

```elm
module Main exposing (..)

import Browser exposing (Document, document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json exposing (field)
import Recipes.Api as Api exposing (..)
import Recipes.Api.Json as JsonApi
import Update.Pipeline exposing (andMap, save)


type alias Book =
    { id : Maybe Int
    , title : String
    , author : String
    , synopsis : String
    }


bookDecoder : Json.Decoder Book
bookDecoder =
    Json.map4 Book
        (Json.maybe (field "id" Json.int))
        (field "title" Json.string)
        (field "author" Json.string)
        (field "synopsis" Json.string)


type Msg
    = ApiMsg (Api.Msg Book)
    | FetchBook
    | ResetBook


type alias Model =
    { api : Api.Model Book
    }


init : () -> ( Model, Cmd Msg )
init () =
    let
        api =
            JsonApi.init
                { endpoint = "/books/1"
                , method = HttpGet
                , decoder = Json.field "book" bookDecoder
                , headers = []
                }
    in
    save Model
        |> andMap api


fetchBook : Model -> ( Model, Cmd Msg )
fetchBook =
    Api.run ApiMsg Api.sendEmptyRequest


resetBook : Model -> ( Model, Cmd Msg )
resetBook =
    Api.run ApiMsg Api.resetResource


update : Msg -> Model -> ( Model, Cmd Msg )
update msg =
    case msg of
        ApiMsg apiMsg ->
            Api.runUpdate ApiMsg apiMsg apiDefaultHandlers

        FetchBook ->
            fetchBook

        ResetBook ->
            resetBook


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view { api } =
    { title = "Api recipe basic example"
    , body =
        [ case api.resource of
            NotRequested ->
                div
                    []
                    [ button
                        [ onClick FetchBook ]
                        [ text "Fetch a book"
                        ]
                    ]

            Requested ->
                text "Your book is loading..."

            Available { title, synopsis } ->
                div
                    []
                    [ h2 [] [ text title ]
                    , p [] [ text synopsis ]
                    , button
                        [ onClick ResetBook ]
                        [ text "Start over again"
                        ]
                    ]

            Error _ ->
                text "That didn't work as expected."
        ]
    }


main : Program () Model Msg
main =
    document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
```

### Form

> Use the Form recipe to build forms and handle form validation.

Here is how to use this recipe in your program:

1. Import the `Recipes.Form` module:

        import Recipes.Form as Form

#### Example

TODO

### Router

> Use the Router recipe to implement URL routing in single-page applications.

Here is how to use this recipe in your program:

1. Import the `Recipes.Router` module:

        import Recipes.Router as Router exposing (Router)


#### Example

```elm
module Main exposing (..)

import Browser exposing (Document, UrlRequest, application)
import Browser.Navigation as Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Recipes.Router as Router exposing (Router)
import Update.Pipeline exposing (andMap, andThen, save)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, parse)


type alias Flags =
    ()


type Msg
    = RouterMsg Router.Msg


type Page
    = NotFoundPage
    | HomePage
    | AboutPage


type Route
    = Home
    | About


routeParser : Parser (Route -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map About (Parser.s "about")
        ]


type alias Model =
    { router : Router Route
    , page : Page
    }


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init () url key =
    let
        router =
            Router.initMsg RouterMsg (parse routeParser) "" key
    in
    save Model
        |> andMap router
        |> andMap (save HomePage)
        |> andThen (update (Router.onUrlChange RouterMsg url))


handleRouteChange : Url -> Maybe Route -> Model -> ( Model, Cmd Msg )
handleRouteChange _ maybeRoute model =
    case maybeRoute of
        Nothing ->
            save { model | page = NotFoundPage }

        Just Home ->
            save { model | page = HomePage }

        Just About ->
            save { model | page = AboutPage }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RouterMsg routerMsg ->
            model
                |> Router.runUpdate RouterMsg routerMsg { onRouteChange = handleRouteChange }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view { page } =
    { title = "Router recipe example"
    , body =
        [ div []
            [ ul []
                [ li [] [ a [ href "/" ] [ text "Home" ] ]
                , li [] [ a [ href "/about" ] [ text "About" ] ]
                , li [] [ a [ href "/missing" ] [ text "Win a dinosaur" ] ]
                ]
            ]
        , div []
            [ case page of
                HomePage ->
                    text "Home"

                AboutPage ->
                    text "About"

                NotFoundPage ->
                    text "404 Not Found"
            ]
        ]
    }


main : Program Flags Model Msg
main =
    application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlChange = Router.onUrlChange RouterMsg
        , onUrlRequest = Router.onUrlRequest RouterMsg
        }
```

### Session

> The Session recipe allows you to store and persist data using the browser's Storage objects.

Here is how to use this recipe in your program:

1. Import the `Recipes.Session.LocalStorage` module:

        import Recipes.Session.LocalStorage as LocalStorage

#### Example

TODO

### Switch

> Use the Switch recipe to address the need for switching between page contexts in applications.

Here is how to use this recipe in your program:

1. Import the `Recipes.Switch` module:

        import Recipes.Switch as Switch

#### Example

TODO

### WebSocket

> Use this recipe to implement WebSocket functionality.

Here is how to use this recipe in your program:

1. Import the `Recipes.WebSocket` module:

        import Recipes.WebSocket as WebSocket

#### Example
