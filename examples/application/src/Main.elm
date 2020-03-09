module Main exposing (main)

import App exposing (Flags, Model, Msg(..), init, subscriptions, update, view)
import Browser exposing (application)
import Recipes.Router as Router


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
