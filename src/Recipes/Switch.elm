module Recipes.Switch exposing (..)

import Html exposing (Html, text)
import Update.Pipeline exposing (andThen, map, mapCmd, save)


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
    | None


initial : Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
initial =
    None


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
insertAsSwitchIn model s =
    save { model | switch = s }


subscriptions :
    { a1 : { b1 | subscriptions : a1 -> Sub msg1, toMsg : msg1 -> msg }
    , a2 : { b2 | subscriptions : a2 -> Sub msg2, toMsg : msg2 -> msg }
    , a3 : { b3 | subscriptions : a3 -> Sub msg3, toMsg : msg3 -> msg }
    , a4 : { b4 | subscriptions : a4 -> Sub msg4, toMsg : msg4 -> msg }
    , a5 : { b5 | subscriptions : a5 -> Sub msg5, toMsg : msg5 -> msg }
    , a6 : { b6 | subscriptions : a6 -> Sub msg6, toMsg : msg6 -> msg }
    , a7 : { b7 | subscriptions : a7 -> Sub msg7, toMsg : msg7 -> msg }
    , a8 : { b8 | subscriptions : a8 -> Sub msg8, toMsg : msg8 -> msg }
    , a9 : { b9 | subscriptions : a9 -> Sub msg9, toMsg : msg9 -> msg }
    , a10 : { b10 | subscriptions : a10 -> Sub msg10, toMsg : msg10 -> msg }
    , a11 : { b11 | subscriptions : a11 -> Sub msg11, toMsg : msg11 -> msg }
    , a12 : { b12 | subscriptions : a12 -> Sub msg12, toMsg : msg12 -> msg }
    }
    -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
    -> Sub msg
subscriptions { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 } opt =
    let
        appl ({ toMsg } as info) model =
            model
                |> info.subscriptions
                |> Sub.map toMsg
    in
    case opt of
        Opt1 model ->
            appl a1 model

        Opt2 model ->
            appl a2 model

        Opt3 model ->
            appl a3 model

        Opt4 model ->
            appl a4 model

        Opt5 model ->
            appl a5 model

        Opt6 model ->
            appl a6 model

        Opt7 model ->
            appl a7 model

        Opt8 model ->
            appl a8 model

        Opt9 model ->
            appl a9 model

        Opt10 model ->
            appl a10 model

        Opt11 model ->
            appl a11 model

        Opt12 model ->
            appl a12 model

        _ ->
            Sub.none


view :
    { a1 : { b1 | view : a1 -> Html msg1, toMsg : msg1 -> msg }
    , a2 : { b2 | view : a2 -> Html msg2, toMsg : msg2 -> msg }
    , a3 : { b3 | view : a3 -> Html msg3, toMsg : msg3 -> msg }
    , a4 : { b4 | view : a4 -> Html msg4, toMsg : msg4 -> msg }
    , a5 : { b5 | view : a5 -> Html msg5, toMsg : msg5 -> msg }
    , a6 : { b6 | view : a6 -> Html msg6, toMsg : msg6 -> msg }
    , a7 : { b7 | view : a7 -> Html msg7, toMsg : msg7 -> msg }
    , a8 : { b8 | view : a8 -> Html msg8, toMsg : msg8 -> msg }
    , a9 : { b9 | view : a9 -> Html msg9, toMsg : msg9 -> msg }
    , a10 : { b10 | view : a10 -> Html msg10, toMsg : msg10 -> msg }
    , a11 : { b11 | view : a11 -> Html msg11, toMsg : msg11 -> msg }
    , a12 : { b12 | view : a12 -> Html msg12, toMsg : msg12 -> msg }
    }
    -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
    -> Html msg
view { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 } opt =
    let
        appl info model =
            model
                |> info.view
                |> Html.map info.toMsg
    in
    case opt of
        Opt1 model ->
            appl a1 model

        Opt2 model ->
            appl a2 model

        Opt3 model ->
            appl a3 model

        Opt4 model ->
            appl a4 model

        Opt5 model ->
            appl a5 model

        Opt6 model ->
            appl a6 model

        Opt7 model ->
            appl a7 model

        Opt8 model ->
            appl a8 model

        Opt9 model ->
            appl a9 model

        Opt10 model ->
            appl a10 model

        Opt11 model ->
            appl a11 model

        Opt12 model ->
            appl a12 model

        _ ->
            text ""


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
    Switch msg1 msg2 msg3 msg4 msg5 msg6 msg7 msg8 msg9 msg10 msg11 msg12
    ->
        { a1 :
            { e1
                | toModel : a1 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg1 -> msg
                , update : msg1 -> a1 -> ( a1, Cmd msg1 )
            }
        , a2 :
            { e2
                | toModel : a2 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg2 -> msg
                , update : msg2 -> a2 -> ( a2, Cmd msg2 )
            }
        , a3 :
            { e3
                | toModel : a3 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg3 -> msg
                , update : msg3 -> a3 -> ( a3, Cmd msg3 )
            }
        , a4 :
            { e4
                | toModel : a4 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg4 -> msg
                , update : msg4 -> a4 -> ( a4, Cmd msg4 )
            }
        , a5 :
            { e5
                | toModel : a5 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg5 -> msg
                , update : msg5 -> a5 -> ( a5, Cmd msg5 )
            }
        , a6 :
            { e6
                | toModel : a6 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg6 -> msg
                , update : msg6 -> a6 -> ( a6, Cmd msg6 )
            }
        , a7 :
            { e7
                | toModel : a7 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg7 -> msg
                , update : msg7 -> a7 -> ( a7, Cmd msg7 )
            }
        , a8 :
            { e8
                | toModel : a8 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg8 -> msg
                , update : msg8 -> a8 -> ( a8, Cmd msg8 )
            }
        , a9 :
            { e9
                | toModel : a9 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg9 -> msg
                , update : msg9 -> a9 -> ( a9, Cmd msg9 )
            }
        , a10 :
            { e10
                | toModel : a10 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg10 -> msg
                , update : msg10 -> a10 -> ( a10, Cmd msg10 )
            }
        , a11 :
            { e11
                | toModel : a11 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg11 -> msg
                , update : msg11 -> a11 -> ( a11, Cmd msg11 )
            }
        , a12 :
            { e12
                | toModel : a12 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg12 -> msg
                , update : msg12 -> a12 -> ( a12, Cmd msg12 )
            }
        }
    -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
    -> ( Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12, Cmd msg )
update msgS { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 } modelS =
    let
        appl ({ toModel, toMsg } as info) msg model =
            model
                |> info.update msg
                |> mapCmd toMsg
                |> map toModel
    in
    case ( msgS, modelS ) of
        ( Opt1 msg, Opt1 model ) ->
            appl a1 msg model

        ( Opt2 msg, Opt2 model ) ->
            appl a2 msg model

        ( Opt3 msg, Opt3 model ) ->
            appl a3 msg model

        ( Opt4 msg, Opt4 model ) ->
            appl a4 msg model

        ( Opt5 msg, Opt5 model ) ->
            appl a5 msg model

        ( Opt6 msg, Opt6 model ) ->
            appl a6 msg model

        ( Opt7 msg, Opt7 model ) ->
            appl a7 msg model

        ( Opt8 msg, Opt8 model ) ->
            appl a8 msg model

        ( Opt9 msg, Opt9 model ) ->
            appl a9 msg model

        ( Opt10 msg, Opt10 model ) ->
            appl a10 msg model

        ( Opt11 msg, Opt11 model ) ->
            appl a11 msg model

        ( Opt12 msg, Opt12 model ) ->
            appl a12 msg model

        _ ->
            save modelS


init :
    (arg -> { e | init : d -> ( a, Cmd msg ), toModel : a -> b, toMsg : msg -> msg2 })
    -> d
    -> arg
    -> ( b, Cmd msg2 )
init get arg pages =
    let
        ({ toModel, toMsg } as info) =
            get pages
    in
    info.init arg
        |> map toModel
        |> mapCmd toMsg


to :
    (c -> { e | init : arg -> ( a, Cmd msg ), toModel : a -> b, toMsg : msg -> msg2 })
    -> arg
    -> c
    -> f
    -> ( b, Cmd msg2 )
to get arg pages _ =
    let
        ({ toModel, toMsg } as info) =
            get pages
    in
    info.init arg
        |> map toModel
        |> mapCmd toMsg


type alias Info arg m msg m1 msg1 =
    { init : arg -> ( m1, Cmd msg1 )
    , subscriptions : m1 -> Sub msg1
    , update : msg1 -> m1 -> ( m1, Cmd msg1 )
    , view : m1 -> Html msg1
    , toMsg : msg1 -> msg
    , toModel : m1 -> m
    }


type alias Layout2 m1 msg1 a1 m2 msg2 a2 =
    { a1 : Info a1 (OneOf2 m1 m2) (OneOf2 msg1 msg2) m1 msg1
    , a2 : Info a2 (OneOf2 m1 m2) (OneOf2 msg1 msg2) m2 msg2
    , a3 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () ()
    , a4 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () ()
    , a5 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () ()
    , a6 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () ()
    , a7 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () ()
    , a8 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () ()
    , a9 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () ()
    , a10 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () ()
    , a11 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () ()
    , a12 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () ()
    }


layout2 :
    { init : init1, subscriptions : subs1, update : update1, view : view1 }
    -> { init : init2, subscriptions : subs2, update : update2, view : view2 }
    ->
        { a1 :
            { init : init1
            , subscriptions : subs1
            , toModel : a1 -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : msg1 -> Switch msg1 msg2 () () () () () () () () () ()
            , update : update1
            , view : view1
            }
        , a2 :
            { init : init2
            , subscriptions : subs2
            , toModel : a2 -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : msg2 -> Switch msg1 msg2 () () () () () () () () () ()
            , update : update2
            , view : view2
            }
        , a3 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> () -> ( (), Cmd () )
            , view : () -> Html ()
            }
        , a4 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> () -> ( (), Cmd () )
            , view : () -> Html ()
            }
        , a5 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> () -> ( (), Cmd () )
            , view : () -> Html ()
            }
        , a6 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> () -> ( (), Cmd () )
            , view : () -> Html ()
            }
        , a7 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> () -> ( (), Cmd () )
            , view : () -> Html ()
            }
        , a8 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> () -> ( (), Cmd () )
            , view : () -> Html ()
            }
        , a9 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> () -> ( (), Cmd () )
            , view : () -> Html ()
            }
        , a10 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> () -> ( (), Cmd () )
            , view : () -> Html ()
            }
        , a11 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> () -> ( (), Cmd () )
            , view : () -> Html ()
            }
        , a12 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> () -> ( (), Cmd () )
            , view : () -> Html ()
            }
        }
layout2 info1 info2 =
    { a1 = { init = info1.init, update = info1.update, view = info1.view, subscriptions = info1.subscriptions, toMsg = Opt1, toModel = Opt1 }
    , a2 = { init = info2.init, update = info2.update, view = info2.view, subscriptions = info2.subscriptions, toMsg = Opt2, toModel = Opt2 }
    , a3 = { init = always (save ()), update = always save, subscriptions = always Sub.none, view = always (text ""), toMsg = Opt3, toModel = Opt3 }
    , a4 = { init = always (save ()), update = always save, subscriptions = always Sub.none, view = always (text ""), toMsg = Opt4, toModel = Opt4 }
    , a5 = { init = always (save ()), update = always save, subscriptions = always Sub.none, view = always (text ""), toMsg = Opt5, toModel = Opt5 }
    , a6 = { init = always (save ()), update = always save, subscriptions = always Sub.none, view = always (text ""), toMsg = Opt6, toModel = Opt6 }
    , a7 = { init = always (save ()), update = always save, subscriptions = always Sub.none, view = always (text ""), toMsg = Opt7, toModel = Opt7 }
    , a8 = { init = always (save ()), update = always save, subscriptions = always Sub.none, view = always (text ""), toMsg = Opt8, toModel = Opt8 }
    , a9 = { init = always (save ()), update = always save, subscriptions = always Sub.none, view = always (text ""), toMsg = Opt9, toModel = Opt9 }
    , a10 = { init = always (save ()), update = always save, subscriptions = always Sub.none, view = always (text ""), toMsg = Opt10, toModel = Opt10 }
    , a11 = { init = always (save ()), update = always save, subscriptions = always Sub.none, view = always (text ""), toMsg = Opt11, toModel = Opt11 }
    , a12 = { init = always (save ()), update = always save, subscriptions = always Sub.none, view = always (text ""), toMsg = Opt12, toModel = Opt12 }
    }


index2 : (({ b | a1 : a } -> a) -> ({ b | a2 : c } -> c) -> e) -> e
index2 a =
    a .a1 .a2


index6 : (({ b | a1 : a } -> a) -> ({ b | a2 : c } -> c) -> ({ b | a3 : e } -> e) -> ({ b | a4 : g } -> g) -> ({ b | a5 : i } -> i) -> ({ b | a6 : k } -> k) -> m) -> m
index6 a =
    a .a1 .a2 .a3 .a4 .a5 .a6


type alias Item1 a b =
    { a | a1 : b } -> b


type alias Item2 a b =
    { a | a2 : b } -> b


type alias Item3 a b =
    { a | a3 : b } -> b


type alias Item4 a b =
    { a | a4 : b } -> b


type alias Item5 a b =
    { a | a5 : b } -> b


type alias Item6 a b =
    { a | a6 : b } -> b


option6 :
    (Bool -> Bool -> Bool -> Bool -> Bool -> Bool -> a)
    -> OneOf6 a1 a2 a3 a4 a5 a6
    -> a
option6 a switch =
    case switch of
        Opt1 _ ->
            --||||------------------------------
            a True False False False False False

        Opt2 _ ->
            --------||||------------------------
            a False True False False False False

        Opt3 _ ->
            --------------||||------------------
            a False False True False False False

        Opt4 _ ->
            --------------------||||------------
            a False False False True False False

        Opt5 _ ->
            --------------------------||||------
            a False False False False True False

        Opt6 _ ->
            --------------------------------||||
            a False False False False False True

        _ ->
            -------------------------------------
            a False False False False False False
