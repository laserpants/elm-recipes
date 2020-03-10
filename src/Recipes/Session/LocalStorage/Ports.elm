port module Recipes.Session.LocalStorage.Ports exposing (clearSession, setSession)


port setSession : String -> Cmd msg


port clearSession : () -> Cmd msg
