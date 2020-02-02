module Recipes.Helpers exposing (Bundle, Extended, andCall, call, runBundle, sequenceCalls, mapExtended, lift)

import Update.Pipeline exposing (save, andAddCmd, mapCmd, sequence)


type alias Extended model a =
    ( model, List a )


mapExtended : (model -> model1) -> Extended model a -> Extended model1 a
mapExtended fun ( model, calls ) =
    ( fun model, calls )


lift : (m -> ( m, Cmd msg )) -> Extended m a -> ( Extended m a, Cmd msg )
lift fun model = 
    let 
        ( ( model1, cmd ), calls ) = mapExtended fun model
    in
    ( ( model1, calls ), cmd )


call : c -> Extended a c -> ( Extended a c, Cmd msg )
call fun ( model, _ ) =
    ( ( model, List.singleton fun ), Cmd.none )


andCall : c -> ( Extended a c, Cmd msg ) -> ( Extended a c, Cmd msg )
andCall fun ( ( model, funs ), cmd ) =
    ( ( model, fun :: funs ), cmd )


type alias Bundle a a1 msg msg1 =
    Extended a1 (a -> ( a, Cmd msg )) -> ( Extended a1 (a -> ( a, Cmd msg )), Cmd msg1 )


sequenceCalls : ( Extended a (a -> ( a, Cmd msg )), Cmd msg ) -> ( a, Cmd msg )
sequenceCalls ( ( model, calls ), cmd ) =
    model
        |> sequence calls
        |> andAddCmd cmd


runBundle :
    (b -> a1)
    -> (a -> b -> model)
    -> (msg1 -> msg)
    -> (a1 -> ( Extended a (model -> ( model, Cmd msg )), Cmd msg1 ))
    -> b
    -> ( model, Cmd msg )
runBundle get set toMsg recipe model =
    get model
        |> recipe
        |> mapCmd toMsg
        |> Tuple.mapFirst (Tuple.mapFirst (\m1 -> set m1 model))
        |> sequenceCalls
