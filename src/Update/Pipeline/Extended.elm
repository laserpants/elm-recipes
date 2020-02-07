module Update.Pipeline.Extended exposing (..)

import Tuple exposing (first, second)
import Update.Pipeline exposing (andAddCmd, andThen, map, mapCmd, save, sequence)


type alias Extended m a =
    ( m, List a )


extend : a -> Extended a c
extend model =
    ( model, [] )


shuffle : Extended ( a, Cmd msg ) c -> ( Extended a c, Cmd msg )
shuffle ( ( model, cmd ), calls ) =
    ( ( model, calls ), cmd )


umap : (a -> b) -> Extended a c -> Extended b c
umap f ( x, calls ) =
    ( f x, calls )


umap2 : (a -> b -> c) -> Extended a d -> Extended b d -> Extended c d
umap2 f ( x, calls1 ) ( y, calls2 ) =
    ( f x y, calls1 ++ calls2 )


umap3 : (a -> b -> c -> d) -> Extended a e -> Extended b e -> Extended c e -> Extended d e
umap3 f ( x, calls1 ) ( y, calls2 ) ( z, calls3 ) =
    ( f x y z, calls1 ++ calls2 ++ calls3 )


lift :
    (a -> ( b, Cmd msg ))
    -> Extended a c
    -> ( Extended b c, Cmd msg )
lift fun a =
    shuffle (umap fun a)


lift2 :
    (a -> b -> ( c, Cmd msg ))
    -> Extended a d
    -> Extended b d
    -> ( Extended c d, Cmd msg )
lift2 fun a b =
    shuffle (umap2 fun a b)


lift3 :
    (a -> b -> c -> ( d, Cmd msg ))
    -> Extended a e
    -> Extended b e
    -> Extended c e
    -> ( Extended d e, Cmd msg )
lift3 fun a b c =
    shuffle (umap3 fun a b c)


andLift :
    (a -> ( b, Cmd msg ))
    -> ( Extended a c, Cmd msg )
    -> ( Extended b c, Cmd msg )
andLift =
    andThen << lift


addCalls : List c -> Extended a c -> ( Extended a c, Cmd msg )
addCalls funs ( model, calls ) =
    save ( model, funs ++ calls )


call : c -> Extended a c -> ( Extended a c, Cmd msg )
call =
    addCalls << List.singleton


andCall : c -> ( Extended a c, Cmd msg ) -> ( Extended a c, Cmd msg )
andCall =
    andThen << call


sequenceCalls : ( a, List (a -> ( a, Cmd msg )) ) -> ( a, Cmd msg )
sequenceCalls ( model, calls ) =
    sequence calls model


type alias Run m m1 msg msg1 a =
    (Extended m1 a -> ( Extended m1 (m -> ( m, Cmd msg )), Cmd msg1 ))
    -> m
    -> ( m, Cmd msg )



--baz what get set toMsg stack model =
--    ( get model, [] )
--        |> stack
--        |> mapCmd toMsg
--        |> andLift (set model)
--        |> andThen (sequenceCalls << what)


runStack_ :
    (d -> m1)
    -> (d -> a -> ( b, Cmd msg ))
    -> (msg1 -> msg)
    -> (( m1, List f ) -> ( Extended a (Extended b c -> ( Extended b c, Cmd msg )), Cmd msg1 ))
    -> Extended d c
    -> ( Extended b c, Cmd msg )
runStack_ get set toMsg stack ( model, calls ) =
    ( get model, [] )
        |> stack
        |> mapCmd toMsg
        |> andLift (set model)
        |> andThen (sequenceCalls << Tuple.mapFirst extend)



--    baz (Tuple.mapFirst extend) get set toMsg stack model
--        |> andThen (addCalls calls)


runStack :
    (a -> m1)
    -> (a -> m1 -> ( m, Cmd msg ))
    -> (msg1 -> msg)
    -> (Extended m1 c -> ( Extended m1 (m -> ( m, Cmd msg )), Cmd msg1 ))
    -> a
    -> ( m, Cmd msg )
runStack get set toMsg stack model =
    ( get model, [] )
        |> stack
        |> mapCmd toMsg
        |> andLift (set model)
        |> andThen sequenceCalls
