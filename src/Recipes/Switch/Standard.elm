module Recipes.Switch.Standard exposing (..)

import Html exposing (Html, span, text)
import Update.Pipeline exposing (..)
import Update.Pipeline.Extended exposing (..)


type Switch a1 a2 a3 a4
    = Opt1 a1
    | Opt2 a2
    | Opt3 a3
    | Opt4 a4
    | Default


type alias OneOf2 a1 a2 =
    Switch a1 a2 () ()


type alias OneOf3 a1 a2 a3 =
    Switch a1 a2 a3 ()


type alias OneOf4 a1 a2 a3 a4 =
    Switch a1 a2 a3 a4


type alias Info init subs update view t =
    { t
        | init : init
        , subscriptions : subs
        , update : update
        , view : view
    }


type alias Info_ page init subs update view =
    { init : init
    , page : page
    , subscriptions : subs
    , update : update
    , view : view
    }


type alias Defaults page m =
    Info_ 
         (Maybe page) 
         ({} -> ( (), Cmd () )) 
         (() -> Sub ()) 
         (() -> m -> ( m, Cmd () )) 
         (() -> Html ())



defaults =
    { init = always (save ())
    , update = always save
    , subscriptions = always Sub.none
    , view = always (text "")
    }


from : a -> Info b c d e f -> Info_ a b c d e 
from opt info =
    { page = opt
    , init = info.init
    , update = info.update
    , subscriptions = info.subscriptions
    , view = info.view
    }


--from2__ :
--    ( t1, Info b1 c1 d1 e1 f1 )
--    -> ( t2, Info b2 c2 d2 e2 f2 )
--    -> { a1 : Info_ (Maybe t1) b1 c1 d1 e1
--       , a2 : Info_ (Maybe t2) b2 c2 d2 e2
--       , a3 : Defaults a b c
--       , a4 : Defaults a b c
--       }
from2 ( opt1, info1 ) ( opt2, info2 ) =
    { a1 = from (Just opt1) info1
    , a2 = from (Just opt2) info2
    , a3 = from Nothing defaults
    , a4 = from Nothing defaults
    }


init opt arg =
    let
        appl toMsg toModel info =
            info.init arg
                |> mapCmd toMsg
                |> map toModel
    in
    case opt of
        Opt1 a1 ->
            appl Opt1 Opt1 a1

        Opt2 a2 ->
            appl Opt2 Opt2 a2

        Opt3 a3 ->
            appl Opt3 Opt3 a3

        Opt4 a4 ->
            appl Opt4 Opt4 a4

        Default ->
            save Default


type alias From2 page m1 msg1 m2 msg2 =
    { a1 : Info_
                (Maybe page)
                (m1 -> ( m1, Cmd msg1 ))
                (m1 -> Sub msg1)
                (msg1 -> m1 -> ( m1 , Cmd msg1 ))
                (m1 -> Html msg1)
    , a2 : Info_
                (Maybe page)
                (m2 -> ( m2, Cmd msg2 ))
                (m2 -> Sub msg2)
                (msg2 -> m2 -> ( m2, Cmd msg2 ))
                (m2 -> Html msg2)
    , a3 : Defaults page ()
    , a4 : Defaults page ()
    }



to page arg { a1, a2, a3, a4 } =
    if a1.page == Just page then
        init (Opt1 a1) arg

    else if a2.page == Just page then
        init (Opt2 a2) arg

    else if a3.page == Just page then
        init (Opt3 a3) arg

    else if a4.page == Just page then
        init (Opt4 a4) arg

    else
        init Default arg


subscriptions { a1, a2, a3, a4 } switch =
    let
        appl toMsg info model =
            model
                |> info.subscriptions
                |> Sub.map toMsg
    in
    case switch of
        Opt1 model ->
            appl Opt1 a1 model

        Opt2 model ->
            appl Opt2 a2 model

        Opt3 model ->
            appl Opt3 a3 model

        Opt4 model ->
            appl Opt4 a4 model

        Default ->
            Sub.none


view { a1, a2, a3, a4 } switch =
    let
        appl toMsg info model =
            model
                |> info.view
                |> Html.map toMsg
    in
    case switch of
        Opt1 model ->
            appl Opt1 a1 model

        Opt2 model ->
            appl Opt2 a2 model

        Opt3 model ->
            appl Opt3 a3 model

        Opt4 model ->
            appl Opt4 a4 model

        Default ->
            text ""


update msgS { a1, a2, a3, a4 } modelS =
    let
        appl ( toMsg, toModel ) info msg model =
            model
                |> info.update msg
                |> mapCmd toMsg
                |> map toModel
    in
    case ( msgS, modelS ) of
        ( Opt1 msg, Opt1 model ) ->
            appl ( Opt1, Opt1 ) a1 msg model

        ( Opt2 msg, Opt2 model ) ->
            appl ( Opt2, Opt2 ) a2 msg model

        ( Opt3 msg, Opt3 model ) ->
            appl ( Opt3, Opt3 ) a3 msg model

        ( Opt4 msg, Opt4 model ) ->
            appl ( Opt4, Opt4 ) a4 msg model

        _ ->
            save modelS


runStack :
    (b -> a2)
    -> (b -> a1 -> ( a, Cmd msg2 ))
    -> (msg1 -> msg2)
    -> c
    -> (c -> a2 -> ( a1, Cmd msg1 ))
    -> b
    -> ( a, Cmd msg2 )
runStack get set toMsg info stack model =
    get model
        |> stack info
        |> mapCmd toMsg
        |> andThen (set model)


type alias HasSwitch a1 a2 a3 a4 a =
    { a | switch : Switch a1 a2 a3 a4 }


insertAsSwitchIn :
    HasSwitch a1 a2 a3 a4 a
    -> Switch a1 a2 a3 a4
    -> ( HasSwitch a1 a2 a3 a4 a, Cmd msg )
insertAsSwitchIn model switch =
    save { model | switch = switch }


run
    : (msg1 -> msg2)
      -> c
      -> (c -> Switch a1 a2 a3 a4 -> ( Switch a1 a2 a3 a4, Cmd msg1 ))
      -> { a | switch : Switch a1 a2 a3 a4 }
      -> ( HasSwitch a1 a2 a3 a4 a, Cmd msg2 )
run =
    runStack .switch insertAsSwitchIn
