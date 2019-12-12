module Recipes.Helpers exposing (Bundle, andCall, call, lift, runBundle, saveLifted, sequenceCalls)

import Update.Pipeline exposing (andAddCmd, mapCmd, save, sequence)


lift : ( a, Cmd msg ) -> ( ( a, List c ), Cmd msg )
lift ( model, cmd ) =
    ( ( model, [] ), cmd )


saveLifted : a -> ( ( a, List c ), Cmd msg )
saveLifted =
    lift << save


call : c -> ( a, List c ) -> ( ( a, List c ), Cmd msg )
call fun ( model, _ ) =
    ( ( model, List.singleton fun ), Cmd.none )


andCall : c -> ( ( a, List c ), Cmd msg ) -> ( ( a, List c ), Cmd msg )
andCall fun ( ( model, funs ), cmd ) =
    ( ( model, fun :: funs ), cmd )


type alias Bundle model1 msg1 model msg =
    model1 -> ( ( model1, List (model -> ( model, Cmd msg )) ), Cmd msg1 )


sequenceCalls : ( ( a, List (a -> ( a, Cmd msg )) ), Cmd msg ) -> ( a, Cmd msg )
sequenceCalls ( ( model, calls ), cmd ) =
    model
        |> sequence calls
        |> andAddCmd cmd


runBundle :
    (model -> model1)
    -> (model1 -> model -> model)
    -> (msg1 -> msg)
    -> Bundle model1 msg1 model msg
    -> model
    -> ( model, Cmd msg )
runBundle get set toMsg updater model =
    get model
        |> updater
        |> mapCmd toMsg
        |> Tuple.mapFirst (Tuple.mapFirst (\m1 -> set m1 model))
        |> sequenceCalls
