module Update.Pipeline.Extended exposing (..)

import Update.Pipeline exposing (andAddCmd, andThen, mapCmd, save, sequence)


type alias Extended m a =
    ( m, List a )


extend : a -> Extended a c
extend model =
    ( model, [] )


shuffle : Extended ( a, Cmd msg ) c -> ( Extended a c, Cmd msg )
shuffle ( ( model, cmd ), calls ) =
    ( ( model, calls ), cmd )


mapM :
    (a -> ( b, Cmd msg ))
    -> Extended a c
    -> ( Extended b c, Cmd msg )
mapM fun =
    shuffle << Tuple.mapFirst fun


andMapM :
    (a -> ( b, Cmd msg ))
    -> ( Extended a c, Cmd msg )
    -> ( Extended b c, Cmd msg )
andMapM =
    andThen << mapM


call : c -> Extended a c -> ( Extended a c, Cmd msg )
call fun ( model, calls ) =
    save ( model, fun :: calls )


andCall : c -> ( Extended a c, Cmd msg ) -> ( Extended a c, Cmd msg )
andCall =
    andThen << call


type alias Stack s t a c k =
    Extended t k -> ( Extended t (s -> ( s, Cmd a )), Cmd c )


runStack :
    (a -> m1)
    -> (a -> m1 -> ( m, Cmd msg ))
    -> (msg1 -> msg)
    -> Stack m m1 msg msg1 c
    -> a
    -> ( m, Cmd msg )
runStack get set toMsg stack model =
    ( get model, [] )
        |> stack
        |> mapCmd toMsg
        |> andMapM (set model)
        |> andThen (\( newModel, calls ) -> sequence calls newModel)
