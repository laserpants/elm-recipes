module Recipes.Session.LocalStorage exposing (..)

import Json.Encode exposing (Value, encode)
import Recipes.Session.LocalStorage.Ports as Ports
import Update.Pipeline exposing (addCmd)


updateStorage : (a -> Value) -> Maybe a -> m -> ( m, Cmd msg )
updateStorage sessionEncoder maybeSession =
    case maybeSession of
        Nothing ->
            addCmd (Ports.clearSession ())

        Just session ->
            let 
                encodedSession = 
                    encode 0 (sessionEncoder session)
            in
            addCmd (Ports.setSession encodedSession)
