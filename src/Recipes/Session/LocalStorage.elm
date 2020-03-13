module Recipes.Session.LocalStorage exposing (clear, updateStorage)

{-| The Session recipe allows you to store and persist data using the browser's Storage objects.
-}

import Json.Encode exposing (Value, encode, null)
import Recipes.Session.LocalStorage.Ports as Ports
import Update.Pipeline exposing (addCmd, save)


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


clear : m -> ( m, Cmd msg )
clear =
    updateStorage (always null) Nothing
