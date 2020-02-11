module Main exposing (..)

import App exposing (..)
import Browser exposing (application)
import Recipes.Router exposing (onUrlChange, onUrlRequest)


main : Program Flags Model Msg
main =
    application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlChange = onUrlChange RouterMsg
        , onUrlRequest = onUrlRequest RouterMsg
        }
