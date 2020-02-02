module Update.Pipeline.Extended exposing (..)

import Update.Pipeline exposing (save, andThen, andAddCmd, sequence, mapCmd)


type alias Extended m a =
    ( m, List a )
    

extend : a -> Extended a c
extend model = 
    ( model, [] )


inject : Extended ( a, Cmd msg ) c -> ( Extended a c, Cmd msg )
inject ( ( model, cmd ), calls ) = 
    ( ( model, calls ), cmd )


lift : 
    (a -> ( b, Cmd msg )) 
    -> Extended a c 
    -> ( Extended b c, Cmd msg )
lift fun = 
    inject << Tuple.mapFirst fun


andLift : 
    (a -> ( b, Cmd msg ))
    -> ( Extended a c, Cmd msg )
    -> ( Extended b c, Cmd msg )
andLift = 
    andThen << lift


call : c -> Extended a c -> ( Extended a c, Cmd msg )
call fun ( model, calls ) = 
    save ( model, fun :: calls )


andCall : c -> ( Extended a c, Cmd msg ) -> ( Extended a c, Cmd msg )
andCall =
    andThen << call


type alias Stack s t a c k =
    Extended t k -> ( Extended t (s -> ( s, Cmd a )), Cmd c )


sequenceCalls : ( a, List (a -> ( a, Cmd msg )) ) -> ( a, Cmd msg )
sequenceCalls ( model, calls ) = 
    model
        |> sequence calls 


runStack : 
    (a -> m1)
    -> (a -> m1 -> ( m, Cmd msg ))
    -> (msg1 -> msg)
    -> Stack m m1 msg msg1 c
    -> a
    -> ( m, Cmd msg )
runStack get set toMsg stack model = 
    get model
        |> extend 
        |> stack
        |> mapCmd toMsg
        |> andLift (set model)
        |> andThen sequenceCalls
