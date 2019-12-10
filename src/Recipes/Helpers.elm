module Recipes.Helpers exposing (andCall, call)


call : c -> ( a, List c ) -> ( ( a, List c ), Cmd msg )
call fun ( model, funs ) =
    ( ( model, List.singleton fun ), Cmd.none )


andCall : c -> ( ( a, List c ), Cmd msg ) -> ( ( a, List c ), Cmd msg )
andCall fun ( ( model, funs ), cmd ) =
    ( ( model, fun :: funs ), cmd )
