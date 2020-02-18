module Recipes.Switch exposing (..)

import Html exposing (Html, text)
import Update.Pipeline exposing (save, map, mapCmd, andThen)


type Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
    = Opt1 a1
    | Opt2 a2
    | Opt3 a3
    | Opt4 a4
    | Opt5 a5
    | Opt6 a6
    | Opt7 a7
    | Opt8 a8
    | Opt9 a9
    | Opt10 a10
    | Opt11 a11
    | Opt12 a12
    | Miss


type alias OneOf2 a1 a2 =
    Switch a1 a2 () () () () () () () () () ()


type alias OneOf3 a1 a2 a3 =
    Switch a1 a2 a3 () () () () () () () () ()


type alias OneOf4 a1 a2 a3 a4 =
    Switch a1 a2 a3 a4 () () () () () () () ()


type alias OneOf5 a1 a2 a3 a4 a5 =
    Switch a1 a2 a3 a4 a5 () () () () () () ()


type alias OneOf6 a1 a2 a3 a4 a5 a6 =
    Switch a1 a2 a3 a4 a5 a6 () () () () () ()


type alias OneOf7 a1 a2 a3 a4 a5 a6 a7 =
    Switch a1 a2 a3 a4 a5 a6 a7 () () () () ()


type alias OneOf8 a1 a2 a3 a4 a5 a6 a7 a8 =
    Switch a1 a2 a3 a4 a5 a6 a7 a8 () () () ()


type alias OneOf9 a1 a2 a3 a4 a5 a6 a7 a8 a9 =
    Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 () () ()


type alias OneOf10 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 =
    Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 () ()


type alias OneOf11 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 =
    Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 ()


type alias OneOf12 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 =
    Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12


type alias HasSwitch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a =
    { a | switch : Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 }


insertAsSwitchIn :
    HasSwitch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a
    -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
    -> ( HasSwitch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a, Cmd msg )
insertAsSwitchIn model switch_ =
    save { model | switch = switch_ }


switch :
    Switch { a | init : b -> ( a1, Cmd msg1 ) } { a | init : b -> ( a2, Cmd msg2 ) } { a | init : b -> ( a3, Cmd msg3 ) } { a | init : b -> ( a4, Cmd msg4 ) } { a | init : b -> ( a5, Cmd msg5 ) } { a | init : b -> ( a6, Cmd msg6 ) } { a | init : b -> ( a7, Cmd msg7 ) } { a | init : b -> ( a8, Cmd msg8 ) } { a | init : b -> ( a9, Cmd msg9 ) } { a | init : b -> ( a10, Cmd msg10 ) } { a | init : b -> ( a11, Cmd msg11 ) } { a | init : b -> ( a12, Cmd msg12 ) }
    -> b
    -> ( Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12, Cmd (Switch msg1 msg2 msg3 msg4 msg5 msg6 msg7 msg8 msg9 msg10 msg11 msg12) )
switch opt arg =
    let
        appl ( toMsg, toModel ) info =
            info.init arg
                |> mapCmd toMsg
                |> map toModel
    in
    case opt of
        Opt1 a1 ->
            appl ( Opt1, Opt1 ) a1

        Opt2 a2 ->
            appl ( Opt2, Opt2 ) a2

        Opt3 a3 ->
            appl ( Opt3, Opt3 ) a3

        Opt4 a4 ->
            appl ( Opt4, Opt4 ) a4

        Opt5 a5 ->
            appl ( Opt5, Opt5 ) a5

        Opt6 a6 ->
            appl ( Opt6, Opt6 ) a6

        Opt7 a7 ->
            appl ( Opt7, Opt7 ) a7

        Opt8 a8 ->
            appl ( Opt8, Opt8 ) a8

        Opt9 a9 ->
            appl ( Opt9, Opt9 ) a9

        Opt10 a10 ->
            appl ( Opt10, Opt10 ) a10

        Opt11 a11 ->
            appl ( Opt11, Opt11 ) a11

        Opt12 a12 ->
            appl ( Opt12, Opt12 ) a12

        Miss ->
            save Miss


subscriptions :
    { a
        | a1 : { b1 | subscriptions : a1 -> Sub msg1 }
        , a2 : { b2 | subscriptions : a2 -> Sub msg2 }
        , a3 : { b3 | subscriptions : a3 -> Sub msg3 }
        , a4 : { b4 | subscriptions : a4 -> Sub msg4 }
        , a5 : { b5 | subscriptions : a5 -> Sub msg5 }
        , a6 : { b6 | subscriptions : a6 -> Sub msg6 }
        , a7 : { b7 | subscriptions : a7 -> Sub msg7 }
        , a8 : { b8 | subscriptions : a8 -> Sub msg8 }
        , a9 : { b9 | subscriptions : a9 -> Sub msg9 }
        , a10 : { b10 | subscriptions : a10 -> Sub msg10 }
        , a11 : { b11 | subscriptions : a11 -> Sub msg11 }
        , a12 : { b12 | subscriptions : a12 -> Sub msg12 }
    }
    -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
    -> Sub (Switch msg1 msg2 msg3 msg4 msg5 msg6 msg7 msg8 msg9 msg10 msg11 msg12)
subscriptions { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 } opt =
    let
        appl toMsg info model =
            model
                |> info.subscriptions
                |> Sub.map toMsg
    in
    case opt of
        Opt1 model ->
            appl Opt1 a1 model

        Opt2 model ->
            appl Opt2 a2 model

        Opt3 model ->
            appl Opt3 a3 model

        Opt4 model ->
            appl Opt4 a4 model

        Opt5 model ->
            appl Opt5 a5 model

        Opt6 model ->
            appl Opt6 a6 model

        Opt7 model ->
            appl Opt7 a7 model

        Opt8 model ->
            appl Opt8 a8 model

        Opt9 model ->
            appl Opt9 a9 model

        Opt10 model ->
            appl Opt10 a10 model

        Opt11 model ->
            appl Opt11 a11 model

        Opt12 model ->
            appl Opt12 a12 model

        Miss ->
            Sub.none


view :
    { a
        | a1 : { b1 | view : a1 -> Html msg1 }
        , a2 : { b2 | view : a2 -> Html msg2 }
        , a3 : { b3 | view : a3 -> Html msg3 }
        , a4 : { b4 | view : a4 -> Html msg4 }
        , a5 : { b5 | view : a5 -> Html msg5 }
        , a6 : { b6 | view : a6 -> Html msg6 }
        , a7 : { b7 | view : a7 -> Html msg7 }
        , a8 : { b8 | view : a8 -> Html msg8 }
        , a9 : { b9 | view : a9 -> Html msg9 }
        , a10 : { b10 | view : a10 -> Html msg10 }
        , a11 : { b11 | view : a11 -> Html msg11 }
        , a12 : { b12 | view : a12 -> Html msg12 }
    }
    -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
    -> Html (Switch msg1 msg2 msg3 msg4 msg5 msg6 msg7 msg8 msg9 msg10 msg11 msg12)
view { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 } opt =
    let
        appl toMsg info model =
            model
                |> info.view
                |> Html.map toMsg
    in
    case opt of
        Opt1 model ->
            appl Opt1 a1 model

        Opt2 model ->
            appl Opt2 a2 model

        Opt3 model ->
            appl Opt3 a3 model

        Opt4 model ->
            appl Opt4 a4 model

        Opt5 model ->
            appl Opt5 a5 model

        Opt6 model ->
            appl Opt6 a6 model

        Opt7 model ->
            appl Opt7 a7 model

        Opt8 model ->
            appl Opt8 a8 model

        Opt9 model ->
            appl Opt9 a9 model

        Opt10 model ->
            appl Opt10 a10 model

        Opt11 model ->
            appl Opt11 a11 model

        Opt12 model ->
            appl Opt12 a12 model

        Miss ->
            text ""


from :
    page
    ->
        { a
            | init : init
            , subscriptions : subs
            , update : update
            , view : view
        }
    ->
        { page : page
        , init : init
        , subscriptions : subs
        , update : update
        , view : view
        }
from opt info =
    { page = opt
    , init = info.init
    , update = info.update
    , subscriptions = info.subscriptions
    , view = info.view
    }


defaults :
    { init : b1 -> ( (), Cmd msg1 )
    , subscriptions : b2 -> Sub msg2
    , update : b3 -> a -> ( a, Cmd msg3 )
    , view : b4 -> Html msg4
    }
defaults =
    { init = always (save ())
    , update = always save
    , subscriptions = always Sub.none
    , view = always (text "")
    }


type alias Info page init subs update view =
    { init : init
    , page : page
    , subscriptions : subs
    , update : update
    , view : view
    }


type alias Defaults page m =
    Info (Maybe page) ({} -> ( (), Cmd () )) (() -> Sub ()) (() -> m -> ( m, Cmd () )) (() -> Html ())


type alias Layout2 page m1 msg1 m2 msg2 =
    { a1 :
        Info (Maybe page) (m1 -> ( m1, Cmd msg1 )) (m1 -> Sub msg1) (msg1 -> m1 -> ( m1, Cmd msg1 )) (m1 -> Html msg1)
    , a2 :
        Info (Maybe page) (m2 -> ( m2, Cmd msg2 )) (m2 -> Sub msg2) (msg2 -> m2 -> ( m2, Cmd msg2 )) (m2 -> Html msg2)
    , a3 : Defaults page ()
    , a4 : Defaults page ()
    , a5 : Defaults page ()
    , a6 : Defaults page ()
    , a7 : Defaults page ()
    , a8 : Defaults page ()
    , a9 : Defaults page ()
    , a10 : Defaults page ()
    , a11 : Defaults page ()
    , a12 : Defaults page ()
    }


type alias Layout3 page m1 msg1 m2 msg2 m3 msg3 =
    { a1 :
        Info (Maybe page) (m1 -> ( m1, Cmd msg1 )) (m1 -> Sub msg1) (msg1 -> m1 -> ( m1, Cmd msg1 )) (m1 -> Html msg1)
    , a2 :
        Info (Maybe page) (m2 -> ( m2, Cmd msg2 )) (m2 -> Sub msg2) (msg2 -> m2 -> ( m2, Cmd msg2 )) (m2 -> Html msg2)
    , a3 :
        Info (Maybe page) (m3 -> ( m3, Cmd msg3 )) (m3 -> Sub msg3) (msg3 -> m3 -> ( m3, Cmd msg3 )) (m3 -> Html msg3)
    , a4 : Defaults page ()
    , a5 : Defaults page ()
    , a6 : Defaults page ()
    , a7 : Defaults page ()
    , a8 : Defaults page ()
    , a9 : Defaults page ()
    , a10 : Defaults page ()
    , a11 : Defaults page ()
    , a12 : Defaults page ()
    }


type alias Layout4 page m1 msg1 m2 msg2 m3 msg3 m4 msg4 =
    { a1 :
        Info (Maybe page) (m1 -> ( m1, Cmd msg1 )) (m1 -> Sub msg1) (msg1 -> m1 -> ( m1, Cmd msg1 )) (m1 -> Html msg1)
    , a2 :
        Info (Maybe page) (m2 -> ( m2, Cmd msg2 )) (m2 -> Sub msg2) (msg2 -> m2 -> ( m2, Cmd msg2 )) (m2 -> Html msg2)
    , a3 :
        Info (Maybe page) (m3 -> ( m3, Cmd msg3 )) (m3 -> Sub msg3) (msg3 -> m3 -> ( m3, Cmd msg3 )) (m3 -> Html msg3)
    , a4 :
        Info (Maybe page) (m4 -> ( m4, Cmd msg4 )) (m4 -> Sub msg4) (msg4 -> m4 -> ( m4, Cmd msg4 )) (m4 -> Html msg4)
    , a5 : Defaults page ()
    , a6 : Defaults page ()
    , a7 : Defaults page ()
    , a8 : Defaults page ()
    , a9 : Defaults page ()
    , a10 : Defaults page ()
    , a11 : Defaults page ()
    , a12 : Defaults page ()
    }


type alias Layout5 page m1 msg1 m2 msg2 m3 msg3 m4 msg4 m5 msg5 =
    { a1 :
        Info (Maybe page) (m1 -> ( m1, Cmd msg1 )) (m1 -> Sub msg1) (msg1 -> m1 -> ( m1, Cmd msg1 )) (m1 -> Html msg1)
    , a2 :
        Info (Maybe page) (m2 -> ( m2, Cmd msg2 )) (m2 -> Sub msg2) (msg2 -> m2 -> ( m2, Cmd msg2 )) (m2 -> Html msg2)
    , a3 :
        Info (Maybe page) (m3 -> ( m3, Cmd msg3 )) (m3 -> Sub msg3) (msg3 -> m3 -> ( m3, Cmd msg3 )) (m3 -> Html msg3)
    , a4 :
        Info (Maybe page) (m4 -> ( m4, Cmd msg4 )) (m4 -> Sub msg4) (msg4 -> m4 -> ( m4, Cmd msg4 )) (m4 -> Html msg4)
    , a5 :
        Info (Maybe page) (m5 -> ( m5, Cmd msg5 )) (m5 -> Sub msg5) (msg5 -> m5 -> ( m5, Cmd msg5 )) (m5 -> Html msg5)
    , a6 : Defaults page ()
    , a7 : Defaults page ()
    , a8 : Defaults page ()
    , a9 : Defaults page ()
    , a10 : Defaults page ()
    , a11 : Defaults page ()
    , a12 : Defaults page ()
    }


type alias Layout6 page m1 msg1 m2 msg2 m3 msg3 m4 msg4 m5 msg5 m6 msg6 =
    { a1 :
        Info (Maybe page) (m1 -> ( m1, Cmd msg1 )) (m1 -> Sub msg1) (msg1 -> m1 -> ( m1, Cmd msg1 )) (m1 -> Html msg1)
    , a2 :
        Info (Maybe page) (m2 -> ( m2, Cmd msg2 )) (m2 -> Sub msg2) (msg2 -> m2 -> ( m2, Cmd msg2 )) (m2 -> Html msg2)
    , a3 :
        Info (Maybe page) (m3 -> ( m3, Cmd msg3 )) (m3 -> Sub msg3) (msg3 -> m3 -> ( m3, Cmd msg3 )) (m3 -> Html msg3)
    , a4 :
        Info (Maybe page) (m4 -> ( m4, Cmd msg4 )) (m4 -> Sub msg4) (msg4 -> m4 -> ( m4, Cmd msg4 )) (m4 -> Html msg4)
    , a5 :
        Info (Maybe page) (m5 -> ( m5, Cmd msg5 )) (m5 -> Sub msg5) (msg5 -> m5 -> ( m5, Cmd msg5 )) (m5 -> Html msg5)
    , a6 :
        Info (Maybe page) (m6 -> ( m6, Cmd msg6 )) (m6 -> Sub msg6) (msg6 -> m6 -> ( m6, Cmd msg6 )) (m6 -> Html msg6)
    , a7 : Defaults page ()
    , a8 : Defaults page ()
    , a9 : Defaults page ()
    , a10 : Defaults page ()
    , a11 : Defaults page ()
    , a12 : Defaults page ()
    }


type alias Layout7 page m1 msg1 m2 msg2 m3 msg3 m4 msg4 m5 msg5 m6 msg6 m7 msg7 =
    { a1 :
        Info (Maybe page) (m1 -> ( m1, Cmd msg1 )) (m1 -> Sub msg1) (msg1 -> m1 -> ( m1, Cmd msg1 )) (m1 -> Html msg1)
    , a2 :
        Info (Maybe page) (m2 -> ( m2, Cmd msg2 )) (m2 -> Sub msg2) (msg2 -> m2 -> ( m2, Cmd msg2 )) (m2 -> Html msg2)
    , a3 :
        Info (Maybe page) (m3 -> ( m3, Cmd msg3 )) (m3 -> Sub msg3) (msg3 -> m3 -> ( m3, Cmd msg3 )) (m3 -> Html msg3)
    , a4 :
        Info (Maybe page) (m4 -> ( m4, Cmd msg4 )) (m4 -> Sub msg4) (msg4 -> m4 -> ( m4, Cmd msg4 )) (m4 -> Html msg4)
    , a5 :
        Info (Maybe page) (m5 -> ( m5, Cmd msg5 )) (m5 -> Sub msg5) (msg5 -> m5 -> ( m5, Cmd msg5 )) (m5 -> Html msg5)
    , a6 :
        Info (Maybe page) (m6 -> ( m6, Cmd msg6 )) (m6 -> Sub msg6) (msg6 -> m6 -> ( m6, Cmd msg6 )) (m6 -> Html msg6)
    , a7 :
        Info (Maybe page) (m7 -> ( m7, Cmd msg7 )) (m7 -> Sub msg7) (msg7 -> m7 -> ( m7, Cmd msg7 )) (m7 -> Html msg7)
    , a8 : Defaults page ()
    , a9 : Defaults page ()
    , a10 : Defaults page ()
    , a11 : Defaults page ()
    , a12 : Defaults page ()
    }


type alias Layout8 page m1 msg1 m2 msg2 m3 msg3 m4 msg4 m5 msg5 m6 msg6 m7 msg7 m8 msg8 =
    { a1 :
        Info (Maybe page) (m1 -> ( m1, Cmd msg1 )) (m1 -> Sub msg1) (msg1 -> m1 -> ( m1, Cmd msg1 )) (m1 -> Html msg1)
    , a2 :
        Info (Maybe page) (m2 -> ( m2, Cmd msg2 )) (m2 -> Sub msg2) (msg2 -> m2 -> ( m2, Cmd msg2 )) (m2 -> Html msg2)
    , a3 :
        Info (Maybe page) (m3 -> ( m3, Cmd msg3 )) (m3 -> Sub msg3) (msg3 -> m3 -> ( m3, Cmd msg3 )) (m3 -> Html msg3)
    , a4 :
        Info (Maybe page) (m4 -> ( m4, Cmd msg4 )) (m4 -> Sub msg4) (msg4 -> m4 -> ( m4, Cmd msg4 )) (m4 -> Html msg4)
    , a5 :
        Info (Maybe page) (m5 -> ( m5, Cmd msg5 )) (m5 -> Sub msg5) (msg5 -> m5 -> ( m5, Cmd msg5 )) (m5 -> Html msg5)
    , a6 :
        Info (Maybe page) (m6 -> ( m6, Cmd msg6 )) (m6 -> Sub msg6) (msg6 -> m6 -> ( m6, Cmd msg6 )) (m6 -> Html msg6)
    , a7 :
        Info (Maybe page) (m7 -> ( m7, Cmd msg7 )) (m7 -> Sub msg7) (msg7 -> m7 -> ( m7, Cmd msg7 )) (m7 -> Html msg7)
    , a8 :
        Info (Maybe page) (m8 -> ( m8, Cmd msg8 )) (m8 -> Sub msg8) (msg8 -> m8 -> ( m8, Cmd msg8 )) (m8 -> Html msg8)
    , a9 : Defaults page ()
    , a10 : Defaults page ()
    , a11 : Defaults page ()
    , a12 : Defaults page ()
    }


type alias Layout9 page m1 msg1 m2 msg2 m3 msg3 m4 msg4 m5 msg5 m6 msg6 m7 msg7 m8 msg8 m9 msg9 =
    { a1 :
        Info (Maybe page) (m1 -> ( m1, Cmd msg1 )) (m1 -> Sub msg1) (msg1 -> m1 -> ( m1, Cmd msg1 )) (m1 -> Html msg1)
    , a2 :
        Info (Maybe page) (m2 -> ( m2, Cmd msg2 )) (m2 -> Sub msg2) (msg2 -> m2 -> ( m2, Cmd msg2 )) (m2 -> Html msg2)
    , a3 :
        Info (Maybe page) (m3 -> ( m3, Cmd msg3 )) (m3 -> Sub msg3) (msg3 -> m3 -> ( m3, Cmd msg3 )) (m3 -> Html msg3)
    , a4 :
        Info (Maybe page) (m4 -> ( m4, Cmd msg4 )) (m4 -> Sub msg4) (msg4 -> m4 -> ( m4, Cmd msg4 )) (m4 -> Html msg4)
    , a5 :
        Info (Maybe page) (m5 -> ( m5, Cmd msg5 )) (m5 -> Sub msg5) (msg5 -> m5 -> ( m5, Cmd msg5 )) (m5 -> Html msg5)
    , a6 :
        Info (Maybe page) (m6 -> ( m6, Cmd msg6 )) (m6 -> Sub msg6) (msg6 -> m6 -> ( m6, Cmd msg6 )) (m6 -> Html msg6)
    , a7 :
        Info (Maybe page) (m7 -> ( m7, Cmd msg7 )) (m7 -> Sub msg7) (msg7 -> m7 -> ( m7, Cmd msg7 )) (m7 -> Html msg7)
    , a8 :
        Info (Maybe page) (m8 -> ( m8, Cmd msg8 )) (m8 -> Sub msg8) (msg8 -> m8 -> ( m8, Cmd msg8 )) (m8 -> Html msg8)
    , a9 :
        Info (Maybe page) (m9 -> ( m9, Cmd msg9 )) (m9 -> Sub msg9) (msg9 -> m9 -> ( m9, Cmd msg9 )) (m9 -> Html msg9)
    , a10 : Defaults page ()
    , a11 : Defaults page ()
    , a12 : Defaults page ()
    }


type alias Layout10 page m1 msg1 m2 msg2 m3 msg3 m4 msg4 m5 msg5 m6 msg6 m7 msg7 m8 msg8 m9 msg9 m10 msg10 =
    { a1 :
        Info (Maybe page) (m1 -> ( m1, Cmd msg1 )) (m1 -> Sub msg1) (msg1 -> m1 -> ( m1, Cmd msg1 )) (m1 -> Html msg1)
    , a2 :
        Info (Maybe page) (m2 -> ( m2, Cmd msg2 )) (m2 -> Sub msg2) (msg2 -> m2 -> ( m2, Cmd msg2 )) (m2 -> Html msg2)
    , a3 :
        Info (Maybe page) (m3 -> ( m3, Cmd msg3 )) (m3 -> Sub msg3) (msg3 -> m3 -> ( m3, Cmd msg3 )) (m3 -> Html msg3)
    , a4 :
        Info (Maybe page) (m4 -> ( m4, Cmd msg4 )) (m4 -> Sub msg4) (msg4 -> m4 -> ( m4, Cmd msg4 )) (m4 -> Html msg4)
    , a5 :
        Info (Maybe page) (m5 -> ( m5, Cmd msg5 )) (m5 -> Sub msg5) (msg5 -> m5 -> ( m5, Cmd msg5 )) (m5 -> Html msg5)
    , a6 :
        Info (Maybe page) (m6 -> ( m6, Cmd msg6 )) (m6 -> Sub msg6) (msg6 -> m6 -> ( m6, Cmd msg6 )) (m6 -> Html msg6)
    , a7 :
        Info (Maybe page) (m7 -> ( m7, Cmd msg7 )) (m7 -> Sub msg7) (msg7 -> m7 -> ( m7, Cmd msg7 )) (m7 -> Html msg7)
    , a8 :
        Info (Maybe page) (m8 -> ( m8, Cmd msg8 )) (m8 -> Sub msg8) (msg8 -> m8 -> ( m8, Cmd msg8 )) (m8 -> Html msg8)
    , a9 :
        Info (Maybe page) (m9 -> ( m9, Cmd msg9 )) (m9 -> Sub msg9) (msg9 -> m9 -> ( m9, Cmd msg9 )) (m9 -> Html msg9)
    , a10 :
        Info (Maybe page) (m10 -> ( m10, Cmd msg10 )) (m10 -> Sub msg10) (msg10 -> m10 -> ( m10, Cmd msg10 )) (m10 -> Html msg10)
    , a11 : Defaults page ()
    , a12 : Defaults page ()
    }


type alias Layout11 page m1 msg1 m2 msg2 m3 msg3 m4 msg4 m5 msg5 m6 msg6 m7 msg7 m8 msg8 m9 msg9 m10 msg10 m11 msg11 =
    { a1 :
        Info (Maybe page) (m1 -> ( m1, Cmd msg1 )) (m1 -> Sub msg1) (msg1 -> m1 -> ( m1, Cmd msg1 )) (m1 -> Html msg1)
    , a2 :
        Info (Maybe page) (m2 -> ( m2, Cmd msg2 )) (m2 -> Sub msg2) (msg2 -> m2 -> ( m2, Cmd msg2 )) (m2 -> Html msg2)
    , a3 :
        Info (Maybe page) (m3 -> ( m3, Cmd msg3 )) (m3 -> Sub msg3) (msg3 -> m3 -> ( m3, Cmd msg3 )) (m3 -> Html msg3)
    , a4 :
        Info (Maybe page) (m4 -> ( m4, Cmd msg4 )) (m4 -> Sub msg4) (msg4 -> m4 -> ( m4, Cmd msg4 )) (m4 -> Html msg4)
    , a5 :
        Info (Maybe page) (m5 -> ( m5, Cmd msg5 )) (m5 -> Sub msg5) (msg5 -> m5 -> ( m5, Cmd msg5 )) (m5 -> Html msg5)
    , a6 :
        Info (Maybe page) (m6 -> ( m6, Cmd msg6 )) (m6 -> Sub msg6) (msg6 -> m6 -> ( m6, Cmd msg6 )) (m6 -> Html msg6)
    , a7 :
        Info (Maybe page) (m7 -> ( m7, Cmd msg7 )) (m7 -> Sub msg7) (msg7 -> m7 -> ( m7, Cmd msg7 )) (m7 -> Html msg7)
    , a8 :
        Info (Maybe page) (m8 -> ( m8, Cmd msg8 )) (m8 -> Sub msg8) (msg8 -> m8 -> ( m8, Cmd msg8 )) (m8 -> Html msg8)
    , a9 :
        Info (Maybe page) (m9 -> ( m9, Cmd msg9 )) (m9 -> Sub msg9) (msg9 -> m9 -> ( m9, Cmd msg9 )) (m9 -> Html msg9)
    , a10 :
        Info (Maybe page) (m10 -> ( m10, Cmd msg10 )) (m10 -> Sub msg10) (msg10 -> m10 -> ( m10, Cmd msg10 )) (m10 -> Html msg10)
    , a11 :
        Info (Maybe page) (m11 -> ( m11, Cmd msg11 )) (m11 -> Sub msg11) (msg11 -> m11 -> ( m11, Cmd msg11 )) (m11 -> Html msg11)
    , a12 : Defaults page ()
    }


type alias Layout12 page m1 msg1 m2 msg2 m3 msg3 m4 msg4 m5 msg5 m6 msg6 m7 msg7 m8 msg8 m9 msg9 m10 msg10 m11 msg11 m12 msg12 =
    { a1 :
        Info (Maybe page) (m1 -> ( m1, Cmd msg1 )) (m1 -> Sub msg1) (msg1 -> m1 -> ( m1, Cmd msg1 )) (m1 -> Html msg1)
    , a2 :
        Info (Maybe page) (m2 -> ( m2, Cmd msg2 )) (m2 -> Sub msg2) (msg2 -> m2 -> ( m2, Cmd msg2 )) (m2 -> Html msg2)
    , a3 :
        Info (Maybe page) (m3 -> ( m3, Cmd msg3 )) (m3 -> Sub msg3) (msg3 -> m3 -> ( m3, Cmd msg3 )) (m3 -> Html msg3)
    , a4 :
        Info (Maybe page) (m4 -> ( m4, Cmd msg4 )) (m4 -> Sub msg4) (msg4 -> m4 -> ( m4, Cmd msg4 )) (m4 -> Html msg4)
    , a5 :
        Info (Maybe page) (m5 -> ( m5, Cmd msg5 )) (m5 -> Sub msg5) (msg5 -> m5 -> ( m5, Cmd msg5 )) (m5 -> Html msg5)
    , a6 :
        Info (Maybe page) (m6 -> ( m6, Cmd msg6 )) (m6 -> Sub msg6) (msg6 -> m6 -> ( m6, Cmd msg6 )) (m6 -> Html msg6)
    , a7 :
        Info (Maybe page) (m7 -> ( m7, Cmd msg7 )) (m7 -> Sub msg7) (msg7 -> m7 -> ( m7, Cmd msg7 )) (m7 -> Html msg7)
    , a8 :
        Info (Maybe page) (m8 -> ( m8, Cmd msg8 )) (m8 -> Sub msg8) (msg8 -> m8 -> ( m8, Cmd msg8 )) (m8 -> Html msg8)
    , a9 :
        Info (Maybe page) (m9 -> ( m9, Cmd msg9 )) (m9 -> Sub msg9) (msg9 -> m9 -> ( m9, Cmd msg9 )) (m9 -> Html msg9)
    , a10 :
        Info (Maybe page) (m10 -> ( m10, Cmd msg10 )) (m10 -> Sub msg10) (msg10 -> m10 -> ( m10, Cmd msg10 )) (m10 -> Html msg10)
    , a11 :
        Info (Maybe page) (m11 -> ( m11, Cmd msg11 )) (m11 -> Sub msg11) (msg11 -> m11 -> ( m11, Cmd msg11 )) (m11 -> Html msg11)
    , a12 :
        Info (Maybe page) (m12 -> ( m12, Cmd msg12 )) (m12 -> Sub msg12) (msg12 -> m12 -> ( m12, Cmd msg12 )) (m12 -> Html msg12)
    }


layout2 :
    ( a1, { a | init : b1, subscriptions : c1, update : d1, view : e1 } )
    -> ( a2, { a | init : b2, subscriptions : c2, update : d2, view : e2 } )
    ->
        { a1 : Info (Maybe a1) b1 c1 d1 e1
        , a2 : Info (Maybe a2) b2 c2 d2 e2
        , a3 : Defaults page ()
        , a4 : Defaults page ()
        , a5 : Defaults page ()
        , a6 : Defaults page ()
        , a7 : Defaults page ()
        , a8 : Defaults page ()
        , a9 : Defaults page ()
        , a10 : Defaults page ()
        , a11 : Defaults page ()
        , a12 : Defaults page ()
        }
layout2 ( opt1, info1 ) ( opt2, info2 ) =
    { a1 = from (Just opt1) info1
    , a2 = from (Just opt2) info2
    , a3 = from Nothing defaults
    , a4 = from Nothing defaults
    , a5 = from Nothing defaults
    , a6 = from Nothing defaults
    , a7 = from Nothing defaults
    , a8 = from Nothing defaults
    , a9 = from Nothing defaults
    , a10 = from Nothing defaults
    , a11 = from Nothing defaults
    , a12 = from Nothing defaults
    }


layout3 :
    ( a1, { a | init : b1, subscriptions : c1, update : d1, view : e1 } )
    -> ( a2, { a | init : b2, subscriptions : c2, update : d2, view : e2 } )
    -> ( a3, { a | init : b3, subscriptions : c3, update : d3, view : e3 } )
    ->
        { a1 : Info (Maybe a1) b1 c1 d1 e1
        , a2 : Info (Maybe a2) b2 c2 d2 e2
        , a3 : Info (Maybe a3) b3 c3 d3 e3
        , a4 : Defaults page ()
        , a5 : Defaults page ()
        , a6 : Defaults page ()
        , a7 : Defaults page ()
        , a8 : Defaults page ()
        , a9 : Defaults page ()
        , a10 : Defaults page ()
        , a11 : Defaults page ()
        , a12 : Defaults page ()
        }
layout3 ( opt1, info1 ) ( opt2, info2 ) ( opt3, info3 ) =
    { a1 = from (Just opt1) info1
    , a2 = from (Just opt2) info2
    , a3 = from (Just opt3) info3
    , a4 = from Nothing defaults
    , a5 = from Nothing defaults
    , a6 = from Nothing defaults
    , a7 = from Nothing defaults
    , a8 = from Nothing defaults
    , a9 = from Nothing defaults
    , a10 = from Nothing defaults
    , a11 = from Nothing defaults
    , a12 = from Nothing defaults
    }


layout4 :
    ( a1, { a | init : b1, subscriptions : c1, update : d1, view : e1 } )
    -> ( a2, { a | init : b2, subscriptions : c2, update : d2, view : e2 } )
    -> ( a3, { a | init : b3, subscriptions : c3, update : d3, view : e3 } )
    -> ( a4, { a | init : b4, subscriptions : c4, update : d4, view : e4 } )
    ->
        { a1 : Info (Maybe a1) b1 c1 d1 e1
        , a2 : Info (Maybe a2) b2 c2 d2 e2
        , a3 : Info (Maybe a3) b3 c3 d3 e3
        , a4 : Info (Maybe a4) b4 c4 d4 e4
        , a5 : Defaults page ()
        , a6 : Defaults page ()
        , a7 : Defaults page ()
        , a8 : Defaults page ()
        , a9 : Defaults page ()
        , a10 : Defaults page ()
        , a11 : Defaults page ()
        , a12 : Defaults page ()
        }
layout4 ( opt1, info1 ) ( opt2, info2 ) ( opt3, info3 ) ( opt4, info4 ) =
    { a1 = from (Just opt1) info1
    , a2 = from (Just opt2) info2
    , a3 = from (Just opt3) info3
    , a4 = from (Just opt4) info4
    , a5 = from Nothing defaults
    , a6 = from Nothing defaults
    , a7 = from Nothing defaults
    , a8 = from Nothing defaults
    , a9 = from Nothing defaults
    , a10 = from Nothing defaults
    , a11 = from Nothing defaults
    , a12 = from Nothing defaults
    }


layout5 :
    ( a1, { a | init : b1, subscriptions : c1, update : d1, view : e1 } )
    -> ( a2, { a | init : b2, subscriptions : c2, update : d2, view : e2 } )
    -> ( a3, { a | init : b3, subscriptions : c3, update : d3, view : e3 } )
    -> ( a4, { a | init : b4, subscriptions : c4, update : d4, view : e4 } )
    -> ( a5, { a | init : b5, subscriptions : c5, update : d5, view : e5 } )
    ->
        { a1 : Info (Maybe a1) b1 c1 d1 e1
        , a2 : Info (Maybe a2) b2 c2 d2 e2
        , a3 : Info (Maybe a3) b3 c3 d3 e3
        , a4 : Info (Maybe a4) b4 c4 d4 e4
        , a5 : Info (Maybe a5) b5 c5 d5 e5
        , a6 : Defaults page ()
        , a7 : Defaults page ()
        , a8 : Defaults page ()
        , a9 : Defaults page ()
        , a10 : Defaults page ()
        , a11 : Defaults page ()
        , a12 : Defaults page ()
        }
layout5 ( opt1, info1 ) ( opt2, info2 ) ( opt3, info3 ) ( opt4, info4 ) ( opt5, info5 ) =
    { a1 = from (Just opt1) info1
    , a2 = from (Just opt2) info2
    , a3 = from (Just opt3) info3
    , a4 = from (Just opt4) info4
    , a5 = from (Just opt5) info5
    , a6 = from Nothing defaults
    , a7 = from Nothing defaults
    , a8 = from Nothing defaults
    , a9 = from Nothing defaults
    , a10 = from Nothing defaults
    , a11 = from Nothing defaults
    , a12 = from Nothing defaults
    }


layout6 :
    ( a1, { a | init : b1, subscriptions : c1, update : d1, view : e1 } )
    -> ( a2, { a | init : b2, subscriptions : c2, update : d2, view : e2 } )
    -> ( a3, { a | init : b3, subscriptions : c3, update : d3, view : e3 } )
    -> ( a4, { a | init : b4, subscriptions : c4, update : d4, view : e4 } )
    -> ( a5, { a | init : b5, subscriptions : c5, update : d5, view : e5 } )
    -> ( a6, { a | init : b6, subscriptions : c6, update : d6, view : e6 } )
    ->
        { a1 : Info (Maybe a1) b1 c1 d1 e1
        , a2 : Info (Maybe a2) b2 c2 d2 e2
        , a3 : Info (Maybe a3) b3 c3 d3 e3
        , a4 : Info (Maybe a4) b4 c4 d4 e4
        , a5 : Info (Maybe a5) b5 c5 d5 e5
        , a6 : Info (Maybe a6) b6 c6 d6 e6
        , a7 : Defaults page ()
        , a8 : Defaults page ()
        , a9 : Defaults page ()
        , a10 : Defaults page ()
        , a11 : Defaults page ()
        , a12 : Defaults page ()
        }
layout6 ( opt1, info1 ) ( opt2, info2 ) ( opt3, info3 ) ( opt4, info4 ) ( opt5, info5 ) ( opt6, info6 ) =
    { a1 = from (Just opt1) info1
    , a2 = from (Just opt2) info2
    , a3 = from (Just opt3) info3
    , a4 = from (Just opt4) info4
    , a5 = from (Just opt5) info5
    , a6 = from (Just opt6) info6
    , a7 = from Nothing defaults
    , a8 = from Nothing defaults
    , a9 = from Nothing defaults
    , a10 = from Nothing defaults
    , a11 = from Nothing defaults
    , a12 = from Nothing defaults
    }


layout7 :
    ( a1, { a | init : b1, subscriptions : c1, update : d1, view : e1 } )
    -> ( a2, { a | init : b2, subscriptions : c2, update : d2, view : e2 } )
    -> ( a3, { a | init : b3, subscriptions : c3, update : d3, view : e3 } )
    -> ( a4, { a | init : b4, subscriptions : c4, update : d4, view : e4 } )
    -> ( a5, { a | init : b5, subscriptions : c5, update : d5, view : e5 } )
    -> ( a6, { a | init : b6, subscriptions : c6, update : d6, view : e6 } )
    -> ( a7, { a | init : b7, subscriptions : c7, update : d7, view : e7 } )
    ->
        { a1 : Info (Maybe a1) b1 c1 d1 e1
        , a2 : Info (Maybe a2) b2 c2 d2 e2
        , a3 : Info (Maybe a3) b3 c3 d3 e3
        , a4 : Info (Maybe a4) b4 c4 d4 e4
        , a5 : Info (Maybe a5) b5 c5 d5 e5
        , a6 : Info (Maybe a6) b6 c6 d6 e6
        , a7 : Info (Maybe a7) b7 c7 d7 e7
        , a8 : Defaults page ()
        , a9 : Defaults page ()
        , a10 : Defaults page ()
        , a11 : Defaults page ()
        , a12 : Defaults page ()
        }
layout7 ( opt1, info1 ) ( opt2, info2 ) ( opt3, info3 ) ( opt4, info4 ) ( opt5, info5 ) ( opt6, info6 ) ( opt7, info7 ) =
    { a1 = from (Just opt1) info1
    , a2 = from (Just opt2) info2
    , a3 = from (Just opt3) info3
    , a4 = from (Just opt4) info4
    , a5 = from (Just opt5) info5
    , a6 = from (Just opt6) info6
    , a7 = from (Just opt7) info7
    , a8 = from Nothing defaults
    , a9 = from Nothing defaults
    , a10 = from Nothing defaults
    , a11 = from Nothing defaults
    , a12 = from Nothing defaults
    }


layout8 :
    ( a1, { a | init : b1, subscriptions : c1, update : d1, view : e1 } )
    -> ( a2, { a | init : b2, subscriptions : c2, update : d2, view : e2 } )
    -> ( a3, { a | init : b3, subscriptions : c3, update : d3, view : e3 } )
    -> ( a4, { a | init : b4, subscriptions : c4, update : d4, view : e4 } )
    -> ( a5, { a | init : b5, subscriptions : c5, update : d5, view : e5 } )
    -> ( a6, { a | init : b6, subscriptions : c6, update : d6, view : e6 } )
    -> ( a7, { a | init : b7, subscriptions : c7, update : d7, view : e7 } )
    -> ( a8, { a | init : b8, subscriptions : c8, update : d8, view : e8 } )
    ->
        { a1 : Info (Maybe a1) b1 c1 d1 e1
        , a2 : Info (Maybe a2) b2 c2 d2 e2
        , a3 : Info (Maybe a3) b3 c3 d3 e3
        , a4 : Info (Maybe a4) b4 c4 d4 e4
        , a5 : Info (Maybe a5) b5 c5 d5 e5
        , a6 : Info (Maybe a6) b6 c6 d6 e6
        , a7 : Info (Maybe a7) b7 c7 d7 e7
        , a8 : Info (Maybe a8) b8 c8 d8 e8
        , a9 : Defaults page ()
        , a10 : Defaults page ()
        , a11 : Defaults page ()
        , a12 : Defaults page ()
        }
layout8 ( opt1, info1 ) ( opt2, info2 ) ( opt3, info3 ) ( opt4, info4 ) ( opt5, info5 ) ( opt6, info6 ) ( opt7, info7 ) ( opt8, info8 ) =
    { a1 = from (Just opt1) info1
    , a2 = from (Just opt2) info2
    , a3 = from (Just opt3) info3
    , a4 = from (Just opt4) info4
    , a5 = from (Just opt5) info5
    , a6 = from (Just opt6) info6
    , a7 = from (Just opt7) info7
    , a8 = from (Just opt8) info8
    , a9 = from Nothing defaults
    , a10 = from Nothing defaults
    , a11 = from Nothing defaults
    , a12 = from Nothing defaults
    }


layout9 :
    ( a1, { a | init : b1, subscriptions : c1, update : d1, view : e1 } )
    -> ( a2, { a | init : b2, subscriptions : c2, update : d2, view : e2 } )
    -> ( a3, { a | init : b3, subscriptions : c3, update : d3, view : e3 } )
    -> ( a4, { a | init : b4, subscriptions : c4, update : d4, view : e4 } )
    -> ( a5, { a | init : b5, subscriptions : c5, update : d5, view : e5 } )
    -> ( a6, { a | init : b6, subscriptions : c6, update : d6, view : e6 } )
    -> ( a7, { a | init : b7, subscriptions : c7, update : d7, view : e7 } )
    -> ( a8, { a | init : b8, subscriptions : c8, update : d8, view : e8 } )
    -> ( a9, { a | init : b9, subscriptions : c9, update : d9, view : e9 } )
    ->
        { a1 : Info (Maybe a1) b1 c1 d1 e1
        , a2 : Info (Maybe a2) b2 c2 d2 e2
        , a3 : Info (Maybe a3) b3 c3 d3 e3
        , a4 : Info (Maybe a4) b4 c4 d4 e4
        , a5 : Info (Maybe a5) b5 c5 d5 e5
        , a6 : Info (Maybe a6) b6 c6 d6 e6
        , a7 : Info (Maybe a7) b7 c7 d7 e7
        , a8 : Info (Maybe a8) b8 c8 d8 e8
        , a9 : Info (Maybe a9) b9 c9 d9 e9
        , a10 : Defaults page ()
        , a11 : Defaults page ()
        , a12 : Defaults page ()
        }
layout9 ( opt1, info1 ) ( opt2, info2 ) ( opt3, info3 ) ( opt4, info4 ) ( opt5, info5 ) ( opt6, info6 ) ( opt7, info7 ) ( opt8, info8 ) ( opt9, info9 ) =
    { a1 = from (Just opt1) info1
    , a2 = from (Just opt2) info2
    , a3 = from (Just opt3) info3
    , a4 = from (Just opt4) info4
    , a5 = from (Just opt5) info5
    , a6 = from (Just opt6) info6
    , a7 = from (Just opt7) info7
    , a8 = from (Just opt8) info8
    , a9 = from (Just opt9) info9
    , a10 = from Nothing defaults
    , a11 = from Nothing defaults
    , a12 = from Nothing defaults
    }


layout10 :
    ( a1, { a | init : b1, subscriptions : c1, update : d1, view : e1 } )
    -> ( a2, { a | init : b2, subscriptions : c2, update : d2, view : e2 } )
    -> ( a3, { a | init : b3, subscriptions : c3, update : d3, view : e3 } )
    -> ( a4, { a | init : b4, subscriptions : c4, update : d4, view : e4 } )
    -> ( a5, { a | init : b5, subscriptions : c5, update : d5, view : e5 } )
    -> ( a6, { a | init : b6, subscriptions : c6, update : d6, view : e6 } )
    -> ( a7, { a | init : b7, subscriptions : c7, update : d7, view : e7 } )
    -> ( a8, { a | init : b8, subscriptions : c8, update : d8, view : e8 } )
    -> ( a9, { a | init : b9, subscriptions : c9, update : d9, view : e9 } )
    -> ( a10, { a | init : b10, subscriptions : c10, update : d10, view : e10 } )
    ->
        { a1 : Info (Maybe a1) b1 c1 d1 e1
        , a2 : Info (Maybe a2) b2 c2 d2 e2
        , a3 : Info (Maybe a3) b3 c3 d3 e3
        , a4 : Info (Maybe a4) b4 c4 d4 e4
        , a5 : Info (Maybe a5) b5 c5 d5 e5
        , a6 : Info (Maybe a6) b6 c6 d6 e6
        , a7 : Info (Maybe a7) b7 c7 d7 e7
        , a8 : Info (Maybe a8) b8 c8 d8 e8
        , a9 : Info (Maybe a9) b9 c9 d9 e9
        , a10 : Info (Maybe a10) b10 c10 d10 e10
        , a11 : Defaults page ()
        , a12 : Defaults page ()
        }
layout10 ( opt1, info1 ) ( opt2, info2 ) ( opt3, info3 ) ( opt4, info4 ) ( opt5, info5 ) ( opt6, info6 ) ( opt7, info7 ) ( opt8, info8 ) ( opt9, info9 ) ( opt10, info10 ) =
    { a1 = from (Just opt1) info1
    , a2 = from (Just opt2) info2
    , a3 = from (Just opt3) info3
    , a4 = from (Just opt4) info4
    , a5 = from (Just opt5) info5
    , a6 = from (Just opt6) info6
    , a7 = from (Just opt7) info7
    , a8 = from (Just opt8) info8
    , a9 = from (Just opt9) info9
    , a10 = from (Just opt10) info10
    , a11 = from Nothing defaults
    , a12 = from Nothing defaults
    }


layout11 :
    ( a1, { a | init : b1, subscriptions : c1, update : d1, view : e1 } )
    -> ( a2, { a | init : b2, subscriptions : c2, update : d2, view : e2 } )
    -> ( a3, { a | init : b3, subscriptions : c3, update : d3, view : e3 } )
    -> ( a4, { a | init : b4, subscriptions : c4, update : d4, view : e4 } )
    -> ( a5, { a | init : b5, subscriptions : c5, update : d5, view : e5 } )
    -> ( a6, { a | init : b6, subscriptions : c6, update : d6, view : e6 } )
    -> ( a7, { a | init : b7, subscriptions : c7, update : d7, view : e7 } )
    -> ( a8, { a | init : b8, subscriptions : c8, update : d8, view : e8 } )
    -> ( a9, { a | init : b9, subscriptions : c9, update : d9, view : e9 } )
    -> ( a10, { a | init : b10, subscriptions : c10, update : d10, view : e10 } )
    -> ( a11, { a | init : b11, subscriptions : c11, update : d11, view : e11 } )
    ->
        { a1 : Info (Maybe a1) b1 c1 d1 e1
        , a2 : Info (Maybe a2) b2 c2 d2 e2
        , a3 : Info (Maybe a3) b3 c3 d3 e3
        , a4 : Info (Maybe a4) b4 c4 d4 e4
        , a5 : Info (Maybe a5) b5 c5 d5 e5
        , a6 : Info (Maybe a6) b6 c6 d6 e6
        , a7 : Info (Maybe a7) b7 c7 d7 e7
        , a8 : Info (Maybe a8) b8 c8 d8 e8
        , a9 : Info (Maybe a9) b9 c9 d9 e9
        , a10 : Info (Maybe a10) b10 c10 d10 e10
        , a11 : Info (Maybe a11) b11 c11 d11 e11
        , a12 : Defaults page ()
        }
layout11 ( opt1, info1 ) ( opt2, info2 ) ( opt3, info3 ) ( opt4, info4 ) ( opt5, info5 ) ( opt6, info6 ) ( opt7, info7 ) ( opt8, info8 ) ( opt9, info9 ) ( opt10, info10 ) ( opt11, info11 ) =
    { a1 = from (Just opt1) info1
    , a2 = from (Just opt2) info2
    , a3 = from (Just opt3) info3
    , a4 = from (Just opt4) info4
    , a5 = from (Just opt5) info5
    , a6 = from (Just opt6) info6
    , a7 = from (Just opt7) info7
    , a8 = from (Just opt8) info8
    , a9 = from (Just opt9) info9
    , a10 = from (Just opt10) info10
    , a11 = from (Just opt11) info11
    , a12 = from Nothing defaults
    }


layout12 :
    ( a1, { a | init : b1, subscriptions : c1, update : d1, view : e1 } )
    -> ( a2, { a | init : b2, subscriptions : c2, update : d2, view : e2 } )
    -> ( a3, { a | init : b3, subscriptions : c3, update : d3, view : e3 } )
    -> ( a4, { a | init : b4, subscriptions : c4, update : d4, view : e4 } )
    -> ( a5, { a | init : b5, subscriptions : c5, update : d5, view : e5 } )
    -> ( a6, { a | init : b6, subscriptions : c6, update : d6, view : e6 } )
    -> ( a7, { a | init : b7, subscriptions : c7, update : d7, view : e7 } )
    -> ( a8, { a | init : b8, subscriptions : c8, update : d8, view : e8 } )
    -> ( a9, { a | init : b9, subscriptions : c9, update : d9, view : e9 } )
    -> ( a10, { a | init : b10, subscriptions : c10, update : d10, view : e10 } )
    -> ( a11, { a | init : b11, subscriptions : c11, update : d11, view : e11 } )
    -> ( a12, { a | init : b12, subscriptions : c12, update : d12, view : e12 } )
    ->
        { a1 : Info (Maybe a1) b1 c1 d1 e1
        , a2 : Info (Maybe a2) b2 c2 d2 e2
        , a3 : Info (Maybe a3) b3 c3 d3 e3
        , a4 : Info (Maybe a4) b4 c4 d4 e4
        , a5 : Info (Maybe a5) b5 c5 d5 e5
        , a6 : Info (Maybe a6) b6 c6 d6 e6
        , a7 : Info (Maybe a7) b7 c7 d7 e7
        , a8 : Info (Maybe a8) b8 c8 d8 e8
        , a9 : Info (Maybe a9) b9 c9 d9 e9
        , a10 : Info (Maybe a10) b10 c10 d10 e10
        , a11 : Info (Maybe a11) b11 c11 d11 e11
        , a12 : Info (Maybe a12) b12 c12 d12 e12
        }
layout12 ( opt1, info1 ) ( opt2, info2 ) ( opt3, info3 ) ( opt4, info4 ) ( opt5, info5 ) ( opt6, info6 ) ( opt7, info7 ) ( opt8, info8 ) ( opt9, info9 ) ( opt10, info10 ) ( opt11, info11 ) ( opt12, info12 ) =
    { a1 = from (Just opt1) info1
    , a2 = from (Just opt2) info2
    , a3 = from (Just opt3) info3
    , a4 = from (Just opt4) info4
    , a5 = from (Just opt5) info5
    , a6 = from (Just opt6) info6
    , a7 = from (Just opt7) info7
    , a8 = from (Just opt8) info8
    , a9 = from (Just opt9) info9
    , a10 = from (Just opt10) info10
    , a11 = from (Just opt11) info11
    , a12 = from (Just opt12) info12
    }


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


type alias RunSwitch info m m1 msg msg1 =
    (info -> m1 -> ( m1, Cmd msg1 ))
    -> m
    -> ( m, Cmd msg )


run :
    (msg1 -> msg2)
    -> info
    -> RunSwitch info (HasSwitch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a) (Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12) msg2 msg1
run =
    runStack .switch insertAsSwitchIn


update :
    Switch a1_2 a2_2 a3_2 a4_2 a5_2 a6_2 a7_2 a8_2 a9_2 a10_2 a11_2 a12_2
    ->
        { a
            | a1 : { b1 | update : a1_2 -> a1_1 -> ( a1_1, Cmd a1 ) }
            , a2 : { b2 | update : a2_2 -> a2_1 -> ( a2_1, Cmd a2 ) }
            , a3 : { b3 | update : a3_2 -> a3_1 -> ( a3_1, Cmd a3 ) }
            , a4 : { b4 | update : a4_2 -> a4_1 -> ( a4_1, Cmd a4 ) }
            , a5 : { b5 | update : a5_2 -> a5_1 -> ( a5_1, Cmd a5 ) }
            , a6 : { b6 | update : a6_2 -> a6_1 -> ( a6_1, Cmd a6 ) }
            , a7 : { b7 | update : a7_2 -> a7_1 -> ( a7_1, Cmd a7 ) }
            , a8 : { b8 | update : a8_2 -> a8_1 -> ( a8_1, Cmd a8 ) }
            , a9 : { b9 | update : a9_2 -> a9_1 -> ( a9_1, Cmd a9 ) }
            , a10 : { b10 | update : a10_2 -> a10_1 -> ( a10_1, Cmd a10 ) }
            , a11 : { b11 | update : a11_2 -> a11_1 -> ( a11_1, Cmd a11 ) }
            , a12 : { b12 | update : a12_2 -> a12_1 -> ( a12_1, Cmd a12 ) }
        }
    -> Switch a1_1 a2_1 a3_1 a4_1 a5_1 a6_1 a7_1 a8_1 a9_1 a10_1 a11_1 a12_1
    -> ( Switch a1_1 a2_1 a3_1 a4_1 a5_1 a6_1 a7_1 a8_1 a9_1 a10_1 a11_1 a12_1, Cmd (Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12) )
update msgS { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 } modelS =
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

        ( Opt5 msg, Opt5 model ) ->
            appl ( Opt5, Opt5 ) a5 msg model

        ( Opt6 msg, Opt6 model ) ->
            appl ( Opt6, Opt6 ) a6 msg model

        ( Opt7 msg, Opt7 model ) ->
            appl ( Opt7, Opt7 ) a7 msg model

        ( Opt8 msg, Opt8 model ) ->
            appl ( Opt8, Opt8 ) a8 msg model

        ( Opt9 msg, Opt9 model ) ->
            appl ( Opt9, Opt9 ) a9 msg model

        ( Opt10 msg, Opt10 model ) ->
            appl ( Opt10, Opt10 ) a10 msg model

        ( Opt11 msg, Opt11 model ) ->
            appl ( Opt11, Opt11 ) a11 msg model

        ( Opt12 msg, Opt12 model ) ->
            appl ( Opt12, Opt12 ) a12 msg model

        _ ->
            save modelS


init :
    page
    -> arg
    ->
        { a
            | a1 : { b1 | init : arg -> ( a1, Cmd msg1 ), page : Maybe page }
            , a2 : { b2 | init : arg -> ( a2, Cmd msg2 ), page : Maybe page }
            , a3 : { b3 | init : arg -> ( a3, Cmd msg3 ), page : Maybe page }
            , a4 : { b4 | init : arg -> ( a4, Cmd msg4 ), page : Maybe page }
            , a5 : { b5 | init : arg -> ( a5, Cmd msg5 ), page : Maybe page }
            , a6 : { b6 | init : arg -> ( a6, Cmd msg6 ), page : Maybe page }
            , a7 : { b7 | init : arg -> ( a7, Cmd msg7 ), page : Maybe page }
            , a8 : { b8 | init : arg -> ( a8, Cmd msg8 ), page : Maybe page }
            , a9 : { b9 | init : arg -> ( a9, Cmd msg9 ), page : Maybe page }
            , a10 : { b10 | init : arg -> ( a10, Cmd msg10 ), page : Maybe page }
            , a11 : { b11 | init : arg -> ( a11, Cmd msg11 ), page : Maybe page }
            , a12 : { b12 | init : arg -> ( a12, Cmd msg12 ), page : Maybe page }
        }
    -> ( Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12, Cmd (Switch msg1 msg2 msg3 msg4 msg5 msg6 msg7 msg8 msg9 msg10 msg11 msg12) )
init =
    to


to :
    page
    -> arg
    ->
        { a
            | a1 : { b1 | init : arg -> ( a1, Cmd msg1 ), page : Maybe page }
            , a2 : { b2 | init : arg -> ( a2, Cmd msg2 ), page : Maybe page }
            , a3 : { b3 | init : arg -> ( a3, Cmd msg3 ), page : Maybe page }
            , a4 : { b4 | init : arg -> ( a4, Cmd msg4 ), page : Maybe page }
            , a5 : { b5 | init : arg -> ( a5, Cmd msg5 ), page : Maybe page }
            , a6 : { b6 | init : arg -> ( a6, Cmd msg6 ), page : Maybe page }
            , a7 : { b7 | init : arg -> ( a7, Cmd msg7 ), page : Maybe page }
            , a8 : { b8 | init : arg -> ( a8, Cmd msg8 ), page : Maybe page }
            , a9 : { b9 | init : arg -> ( a9, Cmd msg9 ), page : Maybe page }
            , a10 : { b10 | init : arg -> ( a10, Cmd msg10 ), page : Maybe page }
            , a11 : { b11 | init : arg -> ( a11, Cmd msg11 ), page : Maybe page }
            , a12 : { b12 | init : arg -> ( a12, Cmd msg12 ), page : Maybe page }
        }
    -> ( Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12, Cmd (Switch msg1 msg2 msg3 msg4 msg5 msg6 msg7 msg8 msg9 msg10 msg11 msg12) )
to page arg { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 } =
    if a1.page == Just page then
        switch (Opt1 a1) arg

    else if a2.page == Just page then
        switch (Opt2 a2) arg

    else if a3.page == Just page then
        switch (Opt3 a3) arg

    else if a4.page == Just page then
        switch (Opt4 a4) arg

    else if a5.page == Just page then
        switch (Opt5 a5) arg

    else if a6.page == Just page then
        switch (Opt6 a6) arg

    else if a7.page == Just page then
        switch (Opt7 a7) arg

    else if a8.page == Just page then
        switch (Opt8 a8) arg

    else if a9.page == Just page then
        switch (Opt9 a9) arg

    else if a10.page == Just page then
        switch (Opt10 a10) arg

    else if a11.page == Just page then
        switch (Opt11 a11) arg

    else if a12.page == Just page then
        switch (Opt12 a12) arg

    else
        switch Miss arg
