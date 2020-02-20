port module Recipes.Session.LocalStorage.Ports exposing (..)


port setSession : String -> Cmd msg


port clearSession : () -> Cmd msg
