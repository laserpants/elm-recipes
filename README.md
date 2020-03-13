# Elm Recipes

## About

## How to use

### A note about pipelines

The implementation of this library, as well as many of the examples on this page, rely on the [`elm-update-pipeline`](https://package.elm-lang.org/packages/laserpants/elm-update-pipeline/latest/) package. This implies a style of code where the pipe operator is used rather heavily, to achieve monadic chaining of updates:

```elm
update msg model =
    case msg of
        SomeMsg someMsg ->
            save model
                |> andThen (setPower 100)
                |> andAddCmd someCmd
```

Note however that this is not required for using `elm-recipes`, and I have tried to present code examples also using a more conventional approach.

### Examples

See `examples/application` for an example of all the recipes used together.

## Recipes

### Api

Use the Api recipe for lifecycle management of resources that are available to your application via Restful web services.

1. import

        import Recipes.Api as Api

2. Add a constructor to your `Msg` type:

        type Msg
            = ...
            | ApiMsg (Api.Msg MyResource)

   You can use a different name than `ApiMsg` but make sure to

3. Add an `api` field to your `Model`:

        type alias Model =
            { ...
            , api : Api.Model MyResource
            }


4. init

5. In your `update` function, add a case for the `Msg` constructor introduced in step 1.

        update msg model =
            case msg of
                ApiMsg apiMsg ->
                    model
                        |> Api.runUpdate ApiMsg apiMsg apiDefaultHandlers

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
import Update.Pipeline exposing (andMap, mapCmd, save)


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
        |> andMap (mapCmd ApiMsg api)


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

Use the Form recipe to build forms and handle form validation.

##### Msg

##### Model

##### Init

##### Update

##### Subscriptions

#### Example

TODO

### Router

Use the Router recipe to implement URL routing in single-page applications.

##### Msg

##### Model

##### Init

##### Update

##### Subscriptions

##### Main

#### Example

TODO

### Session

The Session recipe allows you to store and persist data using the browser's Storage objects.

##### Msg

##### Model

##### Init

##### Update

##### Subscriptions

#### Example

TODO

### Switch

Use the Switch recipe to address the need for switching between page contexts in applications.

##### Msg

##### Model

##### Init

##### Update

##### Subscriptions

#### Example

TODO

### WebSocket

Use this recipe to implement WebSocket functionality.

##### Msg

##### Model

##### Init

##### Update

##### Subscriptions

#### Example
