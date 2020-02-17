module Recipes.Switch.Standard exposing (..)

import Html exposing (Html, span, text)
import Update.Pipeline exposing (..)
import Update.Pipeline.Extended exposing (..)
import Recipes.Switch as Switch exposing (Switch_(..), insertAsSwitchIn_, from, init_)


--type Switch a1 a2 a3 a4
--    = Opt1 a1
--    | Opt2 a2
--    | Opt3 a3
--    | Opt4 a4
--    | Default
--
--
--type alias OneOf2 a1 a2 =
--    Switch a1 a2 () ()
--
--
--type alias OneOf3 a1 a2 a3 =
--    Switch a1 a2 a3 ()
--
--
--type alias OneOf4 a1 a2 a3 a4 =
--    Switch a1 a2 a3 a4
--
--
--type alias Info init subs update view t =
--    { t
--        | init : init
--        , subscriptions : subs
--        , update : update
--        , view : view
--    }
--
--
--type alias Info_ page init subs update view =
--    { init : init
--    , page : page
--    , subscriptions : subs
--    , update : update
--    , view : view
--    }
--
--
--type alias Defaults page m =
--    Info_ 
--         (Maybe page) 
--         ({} -> ( (), Cmd () )) 
--         (() -> Sub ()) 
--         (() -> m -> ( m, Cmd () )) 
--         (() -> Html ())
--
--
--
--from : a -> Info b c d e f -> Info_ a b c d e 
--from opt info =
--    { page = opt
--    , init = info.init
--    , update = info.update
--    , subscriptions = info.subscriptions
--    , view = info.view
--    }
--
--
----from2__ :
----    ( t1, Info b1 c1 d1 e1 f1 )
----    -> ( t2, Info b2 c2 d2 e2 f2 )
----    -> { a1 : Info_ (Maybe t1) b1 c1 d1 e1
----       , a2 : Info_ (Maybe t2) b2 c2 d2 e2
----       , a3 : Defaults a b c
----       , a4 : Defaults a b c
----       }
--from2 ( opt1, info1 ) ( opt2, info2 ) =
--    { a1 = from (Just opt1) info1
--    , a2 = from (Just opt2) info2
--    , a3 = from Nothing defaults
--    , a4 = from Nothing defaults
--    }
--
--
--init opt arg =
--    let
--        appl toMsg toModel info =
--            info.init arg
--                |> mapCmd toMsg
--                |> map toModel
--    in
--    case opt of
--        Opt1 a1 ->
--            appl Opt1 Opt1 a1
--
--        Opt2 a2 ->
--            appl Opt2 Opt2 a2
--
--        Opt3 a3 ->
--            appl Opt3 Opt3 a3
--
--        Opt4 a4 ->
--            appl Opt4 Opt4 a4
--
--        Default ->
--            save Default
--
--
--type alias From2 page m1 msg1 m2 msg2 =
--    { a1 : Info_
--                (Maybe page)
--                (m1 -> ( m1, Cmd msg1 ))
--                (m1 -> Sub msg1)
--                (msg1 -> m1 -> ( m1 , Cmd msg1 ))
--                (m1 -> Html msg1)
--    , a2 : Info_
--                (Maybe page)
--                (m2 -> ( m2, Cmd msg2 ))
--                (m2 -> Sub msg2)
--                (msg2 -> m2 -> ( m2, Cmd msg2 ))
--                (m2 -> Html msg2)
--    , a3 : Defaults page ()
--    , a4 : Defaults page ()
--    }
--
--
--
--to page arg { a1, a2, a3, a4 } =
--    if a1.page == Just page then
--        init (Opt1 a1) arg
--
--    else if a2.page == Just page then
--        init (Opt2 a2) arg
--
--    else if a3.page == Just page then
--        init (Opt3 a3) arg
--
--    else if a4.page == Just page then
--        init (Opt4 a4) arg
--
--    else
--        init Default arg
--
--
--subscriptions { a1, a2, a3, a4 } switch =
--    let
--        appl toMsg info model =
--            model
--                |> info.subscriptions
--                |> Sub.map toMsg
--    in
--    case switch of
--        Opt1 model ->
--            appl Opt1 a1 model
--
--        Opt2 model ->
--            appl Opt2 a2 model
--
--        Opt3 model ->
--            appl Opt3 a3 model
--
--        Opt4 model ->
--            appl Opt4 a4 model
--
--        Default ->
--            Sub.none
--
--
--view { a1, a2, a3, a4 } switch =
--    let
--        appl toMsg info model =
--            model
--                |> info.view
--                |> Html.map toMsg
--    in
--    case switch of
--        Opt1 model ->
--            appl Opt1 a1 model
--
--        Opt2 model ->
--            appl Opt2 a2 model
--
--        Opt3 model ->
--            appl Opt3 a3 model
--
--        Opt4 model ->
--            appl Opt4 a4 model
--
--        Default ->
--            text ""
--
--
--update msgS { a1, a2, a3, a4 } modelS =
--    let
--        appl ( toMsg, toModel ) info msg model =
--            model
--                |> info.update msg
--                |> mapCmd toMsg
--                |> map toModel
--    in
--    case ( msgS, modelS ) of
--        ( Opt1 msg, Opt1 model ) ->
--            appl ( Opt1, Opt1 ) a1 msg model
--
--        ( Opt2 msg, Opt2 model ) ->
--            appl ( Opt2, Opt2 ) a2 msg model
--
--        ( Opt3 msg, Opt3 model ) ->
--            appl ( Opt3, Opt3 ) a3 msg model
--
--        ( Opt4 msg, Opt4 model ) ->
--            appl ( Opt4, Opt4 ) a4 msg model
--
--        _ ->
--            save modelS
--
--
--runStack :
--    (b -> a2)
--    -> (b -> a1 -> ( a, Cmd msg2 ))
--    -> (msg1 -> msg2)
--    -> c
--    -> (c -> a2 -> ( a1, Cmd msg1 ))
--    -> b
--    -> ( a, Cmd msg2 )

--type alias HasSwitch a1 a2 a3 a4 a =
--    { a | switch : Switch a1 a2 a3 a4 }
--
--
--insertAsSwitchIn :
--    HasSwitch a1 a2 a3 a4 a
--    -> Switch a1 a2 a3 a4
--    -> ( HasSwitch a1 a2 a3 a4 a, Cmd msg )
--insertAsSwitchIn model switch =
--    save { model | switch = switch }


--type alias RunSwitch info m m1 msg msg1 = 
--    (info -> m1 -> ( m1, Cmd msg1 ))
--    -> m
--    -> ( m, Cmd msg )


--run
--    : (msg1 -> msg2)
--      -> c
--      -> (c -> Switch a1 a2 a3 a4 -> ( Switch a1 a2 a3 a4, Cmd msg1 ))
--      -> { a | switch : Switch a1 a2 a3 a4 }
--      -> ( HasSwitch a1 a2 a3 a4 a, Cmd msg2 )



----------------
--
----------------

x = 3

-- type Switch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 
--     = Opt1 a1
--     | Opt2 a2
--     | Opt3 a3
--     | Opt4 a4
--     | Opt5 a5
--     | Opt6 a6
--     | Opt7 a7
--     | Opt8 a8
--     | Opt9 a9
--     | Opt10 a10
--     | Opt11 a11
--     | Opt12 a12
--     | Miss
-- 
-- 
-- type alias OneOf2_ a1 a2 =
--     Switch_ a1 a2 () () () () () () () () () () 
-- 
-- 
-- type alias OneOf3_ a1 a2 a3 =
--     Switch_ a1 a2 a3 () () () () () () () () () 
-- 
-- 
-- type alias OneOf4_ a1 a2 a3 a4 =
--     Switch_ a1 a2 a3 a4 () () () () () () () () 
-- 
-- 
-- type alias OneOf5_ a1 a2 a3 a4 a5 =
--     Switch_ a1 a2 a3 a4 a5 () () () () () () () 
-- 
-- 
-- type alias OneOf6_ a1 a2 a3 a4 a5 a6 =
--     Switch_ a1 a2 a3 a4 a5 a6 () () () () () () 
-- 
-- 
-- type alias OneOf7_ a1 a2 a3 a4 a5 a6 a7 =
--     Switch_ a1 a2 a3 a4 a5 a6 a7 () () () () () 
-- 
-- 
-- type alias OneOf8_ a1 a2 a3 a4 a5 a6 a7 a8 =
--     Switch_ a1 a2 a3 a4 a5 a6 a7 a8 () () () () 
-- 
-- 
-- type alias OneOf9_ a1 a2 a3 a4 a5 a6 a7 a8 a9 =
--     Switch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 () () () 
-- 
-- 
-- type alias OneOf10_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 =
--     Switch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 () () 
-- 
-- 
-- type alias OneOf11_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 =
--     Switch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 () 
-- 
-- 
-- type alias OneOf12_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 =
--     Switch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
-- 
-- 
-- type alias HasSwitch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a =
--     { a | switch : Switch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 }
-- 
-- 
-- insertAsSwitchIn_ :
--     HasSwitch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a
--     -> Switch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
--     -> ( HasSwitch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a, Cmd msg )
-- insertAsSwitchIn_ model switch =
--     save { model | switch = switch }
-- 
-- 
-- init_ opt arg =
--     let
--         appl ( toMsg, toModel ) info =
--             info.init arg
--                 |> mapCmd toMsg
--                 |> map toModel
--     in
--     case opt of
--         Opt1 a1 ->
--             appl ( Opt1, Opt1 ) a1
-- 
--         Opt2 a2 ->
--             appl ( Opt2, Opt2 ) a2
-- 
--         Opt3 a3 ->
--             appl ( Opt3, Opt3 ) a3
-- 
--         Opt4 a4 ->
--             appl ( Opt4, Opt4 ) a4
-- 
--         Opt5 a5 ->
--             appl ( Opt5, Opt5 ) a5
-- 
--         Opt6 a6 ->
--             appl ( Opt6, Opt6 ) a6
-- 
--         Opt7 a7 ->
--             appl ( Opt7, Opt7 ) a7
-- 
--         Opt8 a8 ->
--             appl ( Opt8, Opt8 ) a8
-- 
--         Opt9 a9 ->
--             appl ( Opt9, Opt9 ) a9
-- 
--         Opt10 a10 ->
--             appl ( Opt10, Opt10 ) a10
-- 
--         Opt11 a11 ->
--             appl ( Opt11, Opt11 ) a11
-- 
--         Opt12 a12 ->
--             appl ( Opt12, Opt12 ) a12
-- 
--         Miss ->
--             save Miss
-- 
-- 
-- subscriptions_ { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 } switch =
--     let
--         appl toMsg info model =
--             model
--                 |> info.subscriptions
--                 |> Sub.map toMsg
--     in
--     case switch of
--         Opt1 model ->
--             appl Opt1 a1 model
-- 
--         Opt2 model ->
--             appl Opt2 a2 model
-- 
--         Opt3 model ->
--             appl Opt3 a3 model
-- 
--         Opt4 model ->
--             appl Opt4 a4 model
-- 
--         Opt5 model ->
--             appl Opt5 a5 model
-- 
--         Opt6 model ->
--             appl Opt6 a6 model
-- 
--         Opt7 model ->
--             appl Opt7 a7 model
-- 
--         Opt8 model ->
--             appl Opt8 a8 model
-- 
--         Opt9 model ->
--             appl Opt9 a9 model
-- 
--         Opt10 model ->
--             appl Opt10 a10 model
-- 
--         Opt11 model ->
--             appl Opt11 a11 model
-- 
--         Opt12 model ->
--             appl Opt12 a12 model
-- 
--         Miss ->
--             Sub.none
-- 
-- 
-- view_ { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 } switch =
--     let
--         appl toMsg info model =
--             model
--                 |> info.view
--                 |> Html.map toMsg
--     in
--     case switch of
--         Opt1 model ->
--             appl Opt1 a1 model
-- 
--         Opt2 model ->
--             appl Opt2 a2 model
-- 
--         Opt3 model ->
--             appl Opt3 a3 model
-- 
--         Opt4 model ->
--             appl Opt4 a4 model
-- 
--         Opt5 model ->
--             appl Opt5 a5 model
-- 
--         Opt6 model ->
--             appl Opt6 a6 model
-- 
--         Opt7 model ->
--             appl Opt7 a7 model
-- 
--         Opt8 model ->
--             appl Opt8 a8 model
-- 
--         Opt9 model ->
--             appl Opt9 a9 model
-- 
--         Opt10 model ->
--             appl Opt10 a10 model
-- 
--         Opt11 model ->
--             appl Opt11 a11 model
-- 
--         Opt12 model ->
--             appl Opt12 a12 model
-- 
--         Miss ->
--             text ""
-- 
-- 
-- from opt info =
--     { page = opt
--     , init = info.init
--     , update = info.update
--     , subscriptions = info.subscriptions
--     , view = info.view
--     }
-- 
-- 
-- defaults =
--     { init = always (save ())
--     , update = always save
--     , subscriptions = always Sub.none
--     , view = always (text "")
--     }
-- 
-- 
-- between2_ defaults ( opt1, info1 ) ( opt2, info2 ) =
--     { a1 = from (Just opt1) info1
--     , a2 = from (Just opt2) info2
--     , a3 = from Nothing defaults
--     , a4 = from Nothing defaults
--     , a5 = from Nothing defaults
--     , a6 = from Nothing defaults
--     , a7 = from Nothing defaults
--     , a8 = from Nothing defaults
--     , a9 = from Nothing defaults
--     , a10 = from Nothing defaults
--     , a11 = from Nothing defaults
--     , a12 = from Nothing defaults
--     }
-- 
-- 
-- runStack get set toMsg info stack model =
--     get model
--         |> stack info
--         |> mapCmd toMsg
--         |> andThen (set model)
-- 
-- 
-- run =
--     runStack .switch insertAsSwitchIn_
-- 
-- 
-- 
-- update_ msgS { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 } modelS =
--     let
--         appl ( toMsg, toModel ) info msg model =
--             model
--                 |> info.update msg 
--                 |> mapCmd toMsg
--                 |> map (mapE toModel)
--     in
--     case ( msgS, modelS ) of
--         ( Opt1 msg, Opt1 model ) ->
--             appl ( Opt1, Opt1 ) a1 msg model
-- 
--         ( Opt2 msg, Opt2 model ) ->
--             appl ( Opt2, Opt2 ) a2 msg model
-- 
--         ( Opt3 msg, Opt3 model ) ->
--             appl ( Opt3, Opt3 ) a3 msg model
-- 
--         ( Opt4 msg, Opt4 model ) ->
--             appl ( Opt4, Opt4 ) a4 msg model
-- 
--         ( Opt5 msg, Opt5 model ) ->
--             appl ( Opt5, Opt5 ) a5 msg model
-- 
--         ( Opt6 msg, Opt6 model ) ->
--             appl ( Opt6, Opt6 ) a6 msg model
-- 
--         ( Opt7 msg, Opt7 model ) ->
--             appl ( Opt7, Opt7 ) a7 msg model
-- 
--         ( Opt8 msg, Opt8 model ) ->
--             appl ( Opt8, Opt8 ) a8 msg model
-- 
--         ( Opt9 msg, Opt9 model ) ->
--             appl ( Opt9, Opt9 ) a9 msg model
-- 
--         ( Opt10 msg, Opt10 model ) ->
--             appl ( Opt10, Opt10 ) a10 msg model
-- 
--         ( Opt11 msg, Opt11 model ) ->
--             appl ( Opt11, Opt11 ) a11 msg model
-- 
--         ( Opt12 msg, Opt12 model ) ->
--             appl ( Opt12, Opt12 ) a12 msg model
-- 
--         _ ->
--             save (extend modelS)
-- 
-- 
-- initTo = 
--     to
-- 
-- 
-- to page arg { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 } =
--     if a1.page == Just page then
--         init_ (Opt1 a1) arg
-- 
--     else if a2.page == Just page then
--         init_ (Opt2 a2) arg
-- 
--     else if a3.page == Just page then
--         init_ (Opt3 a3) arg
-- 
--     else if a4.page == Just page then
--         init_ (Opt4 a4) arg
-- 
--     else if a5.page == Just page then
--         init_ (Opt5 a5) arg
-- 
--     else if a6.page == Just page then
--         init_ (Opt6 a6) arg
-- 
--     else if a7.page == Just page then
--         init_ (Opt7 a7) arg
-- 
--     else if a8.page == Just page then
--         init_ (Opt8 a8) arg
-- 
--     else if a9.page == Just page then
--         init_ (Opt9 a9) arg
-- 
--     else if a10.page == Just page then
--         init_ (Opt10 a10) arg
-- 
--     else if a11.page == Just page then
--         init_ (Opt11 a11) arg
-- 
--     else if a12.page == Just page then
--         init_ (Opt12 a12) arg
-- 
--     else
--         init_ Miss arg
