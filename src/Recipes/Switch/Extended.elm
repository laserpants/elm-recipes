module Recipes.Switch.Extended exposing (..)

import Html exposing (Html, span, text)
import Update.Pipeline exposing (..)
import Update.Pipeline.Extended exposing (..)
import Recipes.Switch as Switch


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


type alias Defaults page handlers m =
    Info_ 
         (Maybe page) 
         ({} -> ( (), Cmd () )) 
         (() -> Sub ()) 
         (() -> handlers -> m -> ( m, Cmd () )) 
         (() -> Html ())


defaults :
    { init : {} -> ( (), Cmd () )
    , subscriptions : () -> Sub ()
    , update : () -> b -> m -> ( m, Cmd () )
    , view : () -> Html ()
    }
defaults =
    { init = always (save ())
    , update = always (always save)
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


type alias From2 page handlers a m1 msg1 m2 msg2 =
    { a1 : Info_
                (Maybe page)
                (m1 -> ( m1, Cmd msg1 ))
                (m1 -> Sub msg1)
                (msg1 -> handlers -> Extended m1 a -> ( Extended m1 a , Cmd msg1 ))
                (m1 -> Html msg1)
    , a2 : Info_
                (Maybe page)
                (m2 -> ( m2, Cmd msg2 ))
                (m2 -> Sub msg2)
                (msg2 -> handlers -> Extended m2 a -> ( Extended m2 a , Cmd msg2 ))
                (m2 -> Html msg2)
    , a3 : Defaults page handlers (Extended () a)
    , a4 : Defaults page handlers (Extended () a)
    }


from4 :
    ( t1, Info b1 c1 d1 e1 f1 )
    -> ( t2, Info b2 c2 d2 e2 f2 )
    -> ( t3, Info b3 c3 d3 e3 f3 )
    -> ( t4, Info b4 c4 d4 e4 f4 )
    -> { a1 : Info_ (Maybe t1) b1 c1 d1 e1
       , a2 : Info_ (Maybe t2) b2 c2 d2 e2
       , a3 : Info_ (Maybe t3) b3 c3 d3 e3
       , a4 : Info_ (Maybe t4) b4 c4 d4 e4
       }
from4 ( opt1, info1 ) ( opt2, info2 ) ( opt3, info3 ) ( opt4, info4 ) =
    { a1 = from (Just opt1) info1
    , a2 = from (Just opt2) info2
    , a3 = from (Just opt3) info3
    , a4 = from (Just opt4) info4
    }


from3 :
    ( t1, Info b1 c1 d1 e1 f1 )
    -> ( t2, Info b2 c2 d2 e2 f2 )
    -> ( t3, Info b3 c3 d3 e3 f3 )
    -> { a1 : Info_ (Maybe t1) b1 c1 d1 e1
       , a2 : Info_ (Maybe t2) b2 c2 d2 e2
       , a3 : Info_ (Maybe t3) b3 c3 d3 e3
       , a4 : Defaults a b c
       }
from3 ( opt1, info1 ) ( opt2, info2 ) ( opt3, info3 ) =
    { a1 = from (Just opt1) info1
    , a2 = from (Just opt2) info2
    , a3 = from (Just opt3) info3
    , a4 = from Nothing defaults
    }


from2 :
    ( t1, Info b1 c1 d1 e1 f1 )
    -> ( t2, Info b2 c2 d2 e2 f2 )
    -> { a1 : Info_ (Maybe t1) b1 c1 d1 e1
       , a2 : Info_ (Maybe t2) b2 c2 d2 e2
       , a3 : Defaults a b c
       , a4 : Defaults a b c
       }
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


toto page arg { a1, a2, a3, a4 } =
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


to page arg { a1, a2, a3, a4 } =
    if a1.page == Just page then
        map extend (init (Opt1 a1) arg)

    else if a2.page == Just page then
        map extend (init (Opt2 a2) arg)

    else if a3.page == Just page then
        map extend (init (Opt3 a3) arg)

    else if a4.page == Just page then
        map extend (init (Opt4 a4) arg)

    else
        map extend (init Default arg)



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


update msgS handlers { a1, a2, a3, a4 } modelS =
    let
        appl toMsg toModel info msg model =
            ( model, [] )
                |> info.update msg handlers
                |> mapCmd toMsg
                |> map (mapE toModel)

    in
    case ( msgS, modelS ) of
        ( Opt1 msg, Opt1 model ) ->
            appl Opt1 Opt1 a1 msg model

        ( Opt2 msg, Opt2 model ) ->
            appl Opt2 Opt2 a2 msg model

        ( Opt3 msg, Opt3 model ) ->
            appl Opt3 Opt3 a3 msg model

        ( Opt4 msg, Opt4 model ) ->
            appl Opt4 Opt4 a4 msg model

        _ ->
            save (extend modelS)


runStack : 
    (c -> a1)
    -> (c -> a -> ( b, Cmd msg2 ))
    -> (msg1 -> msg2)
    -> d
    -> (d -> a1 -> ( Extended a (b -> ( b, Cmd msg2 )), Cmd msg1 ))
    -> c
    -> ( b, Cmd msg2 )
runStack get set toMsg info stack model =
    get model
        |> stack info
        |> mapCmd toMsg
        |> andLift (set model)
        |> andThen sequenceCalls


type alias HasSwitch a1 a2 a3 a4 a =
    { a | switch : Switch a1 a2 a3 a4 }


insertAsSwitchIn :
    HasSwitch a1 a2 a3 a4 a
    -> Switch a1 a2 a3 a4
    -> ( HasSwitch a1 a2 a3 a4 a, Cmd msg )
insertAsSwitchIn model switch =
    save { model | switch = switch }


run : 
    (msg1 -> msg2)
      -> d
      -> (
      d
      -> Switch a1 a2 a3 a4
      -> ( Extended (Switch a1 a2 a3 a4) (HasSwitch a1 a2 a3 a4 a -> ( HasSwitch a1 a2 a3 a4 a, Cmd msg2 )), Cmd msg1) )
      -> { a | switch : Switch a1 a2 a3 a4 }
      -> ( HasSwitch a1 a2 a3 a4 a, Cmd msg2 )
run =
    runStack .switch insertAsSwitchIn
