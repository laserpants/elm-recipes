module Recipes.Switch.Extended exposing (..)

import Html exposing (Html, text)
import Recipes.Switch exposing (Switch(..), insertAsSwitchIn)
import Update.Pipeline exposing (andThen, map, mapCmd, save)
import Update.Pipeline.Extended exposing (Extended, andLift, extend, mapE, sequenceCalls)


type alias Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 =
    Recipes.Switch.Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12


type alias OneOf2 a1 a2 =
    Recipes.Switch.OneOf2 a1 a2


type alias OneOf3 a1 a2 a3 =
    Recipes.Switch.OneOf3 a1 a2 a3


type alias OneOf4 a1 a2 a3 a4 =
    Recipes.Switch.OneOf4 a1 a2 a3 a4


type alias OneOf5 a1 a2 a3 a4 a5 =
    Recipes.Switch.OneOf5 a1 a2 a3 a4 a5


type alias OneOf6 a1 a2 a3 a4 a5 a6 =
    Recipes.Switch.OneOf6 a1 a2 a3 a4 a5 a6


type alias OneOf7 a1 a2 a3 a4 a5 a6 a7 =
    Recipes.Switch.OneOf7 a1 a2 a3 a4 a5 a6 a7


type alias OneOf8 a1 a2 a3 a4 a5 a6 a7 a8 =
    Recipes.Switch.OneOf8 a1 a2 a3 a4 a5 a6 a7 a8


type alias OneOf9 a1 a2 a3 a4 a5 a6 a7 a8 a9 =
    Recipes.Switch.OneOf9 a1 a2 a3 a4 a5 a6 a7 a8 a9


type alias OneOf10 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 =
    Recipes.Switch.OneOf10 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10


type alias OneOf11 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 =
    Recipes.Switch.OneOf11 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11


type alias OneOf12 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 =
    Recipes.Switch.OneOf12 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12


type alias HasSwitch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a =
    Recipes.Switch.HasSwitch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a


insertAsSwitchIn :
    HasSwitch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a
    -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
    -> ( HasSwitch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a, Cmd msg )
insertAsSwitchIn =
    Recipes.Switch.insertAsSwitchIn


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
subscriptions =
    Recipes.Switch.subscriptions


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
view =
    Recipes.Switch.view


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


type alias RunSwitch info m m1 msg msg1 =
    (info -> m1 -> ( Extended m1 (m -> ( m, Cmd msg )), Cmd msg1 ))
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
    -> b
    ->
        { a1 :
            { e1
                | toModel : a1 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg1 -> msg
                , update : msg1 -> b -> ( a1, List c ) -> ( Extended a1 c, Cmd msg1 )
            }
        , a2 :
            { e2
                | toModel : a2 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg2 -> msg
                , update : msg2 -> b -> ( a2, List c ) -> ( Extended a2 c, Cmd msg2 )
            }
        , a3 :
            { e3
                | toModel : a3 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg3 -> msg
                , update : msg3 -> b -> ( a3, List c ) -> ( Extended a3 c, Cmd msg3 )
            }
        , a4 :
            { e4
                | toModel : a4 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg4 -> msg
                , update : msg4 -> b -> ( a4, List c ) -> ( Extended a4 c, Cmd msg4 )
            }
        , a5 :
            { e5
                | toModel : a5 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg5 -> msg
                , update : msg5 -> b -> ( a5, List c ) -> ( Extended a5 c, Cmd msg5 )
            }
        , a6 :
            { e6
                | toModel : a6 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg6 -> msg
                , update : msg6 -> b -> ( a6, List c ) -> ( Extended a6 c, Cmd msg6 )
            }
        , a7 :
            { e7
                | toModel : a7 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg7 -> msg
                , update : msg7 -> b -> ( a7, List c ) -> ( Extended a7 c, Cmd msg7 )
            }
        , a8 :
            { e8
                | toModel : a8 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg8 -> msg
                , update : msg8 -> b -> ( a8, List c ) -> ( Extended a8 c, Cmd msg8 )
            }
        , a9 :
            { e9
                | toModel : a9 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg9 -> msg
                , update : msg9 -> b -> ( a9, List c ) -> ( Extended a9 c, Cmd msg9 )
            }
        , a10 :
            { e10
                | toModel : a10 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg10 -> msg
                , update : msg10 -> b -> ( a10, List c ) -> ( Extended a10 c, Cmd msg10 )
            }
        , a11 :
            { e11
                | toModel : a11 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg11 -> msg
                , update : msg11 -> b -> ( a11, List c ) -> ( Extended a11 c, Cmd msg11 )
            }
        , a12 :
            { e12
                | toModel : a12 -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
                , toMsg : msg12 -> msg
                , update : msg12 -> b -> ( a12, List c ) -> ( Extended a12 c, Cmd msg12 )
            }
        }
    -> Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
    -> ( Extended (Switch a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12) c, Cmd msg )
update msgS handlers { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 } modelS =
    let
        appl ({ toModel, toMsg } as info) msg model =
            ( model, [] )
                |> info.update msg handlers
                |> mapCmd toMsg
                |> map (mapE toModel)
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
            save (extend modelS)


init :
    (arg -> { e | init : d -> ( a, Cmd msg ), toModel : a -> b, toMsg : msg -> msg2 })
    -> d
    -> arg
    -> ( b, Cmd msg2 )
init =
    Recipes.Switch.init


to :
    (c1 -> { e | init : arg -> ( a2, Cmd msg1 ), toModel : a2 -> a, toMsg : msg1 -> msg })
    -> arg
    -> c1
    -> a1
    -> ( Extended a c, Cmd msg )
to get arg pages =
    map extend << Recipes.Switch.to get arg pages


type alias Info arg m msg m1 msg1 h a =
    { init : arg -> ( m1, Cmd msg1 )
    , subscriptions : m1 -> Sub msg1
    , update : msg1 -> h -> Extended m1 a -> ( Extended m1 a, Cmd msg1 )
    , view : m1 -> Html msg1
    , toMsg : msg1 -> msg
    , toModel : m1 -> m
    }


type alias Layout2 h m1 msg1 a1 m2 msg2 a2 a =
    { a1 : Info a1 (OneOf2 m1 m2) (OneOf2 msg1 msg2) m1 msg1 h a
    , a2 : Info a2 (OneOf2 m1 m2) (OneOf2 msg1 msg2) m2 msg2 h a
    , a3 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () () h a
    , a4 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () () h a
    , a5 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () () h a
    , a6 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () () h a
    , a7 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () () h a
    , a8 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () () h a
    , a9 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () () h a
    , a10 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () () h a
    , a11 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () () h a
    , a12 : Info {} (OneOf2 m1 m2) (OneOf2 msg1 msg2) () () h a
    }


type alias Layout6 h m1 msg1 a1 m2 msg2 a2 m3 msg3 a3 m4 msg4 a4 m5 msg5 a5 m6 msg6 a6 a =
    { a1 : Info a1 (OneOf6 m1 m2 m3 m4 m5 m6) (OneOf6 msg1 msg2 msg3 msg4 msg5 msg6) m1 msg1 h a
    , a2 : Info a2 (OneOf6 m1 m2 m3 m4 m5 m6) (OneOf6 msg1 msg2 msg3 msg4 msg5 msg6) m2 msg2 h a
    , a3 : Info a3 (OneOf6 m1 m2 m3 m4 m5 m6) (OneOf6 msg1 msg2 msg3 msg4 msg5 msg6) m3 msg3 h a
    , a4 : Info a4 (OneOf6 m1 m2 m3 m4 m5 m6) (OneOf6 msg1 msg2 msg3 msg4 msg5 msg6) m4 msg4 h a
    , a5 : Info a5 (OneOf6 m1 m2 m3 m4 m5 m6) (OneOf6 msg1 msg2 msg3 msg4 msg5 msg6) m5 msg5 h a
    , a6 : Info a6 (OneOf6 m1 m2 m3 m4 m5 m6) (OneOf6 msg1 msg2 msg3 msg4 msg5 msg6) m6 msg6 h a
    , a7 : Info {} (OneOf6 m1 m2 m3 m4 m5 m6) (OneOf6 msg1 msg2 msg3 msg4 msg5 msg6) () () h a
    , a8 : Info {} (OneOf6 m1 m2 m3 m4 m5 m6) (OneOf6 msg1 msg2 msg3 msg4 msg5 msg6) () () h a
    , a9 : Info {} (OneOf6 m1 m2 m3 m4 m5 m6) (OneOf6 msg1 msg2 msg3 msg4 msg5 msg6) () () h a
    , a10 : Info {} (OneOf6 m1 m2 m3 m4 m5 m6) (OneOf6 msg1 msg2 msg3 msg4 msg5 msg6) () () h a
    , a11 : Info {} (OneOf6 m1 m2 m3 m4 m5 m6) (OneOf6 msg1 msg2 msg3 msg4 msg5 msg6) () () h a
    , a12 : Info {} (OneOf6 m1 m2 m3 m4 m5 m6) (OneOf6 msg1 msg2 msg3 msg4 msg5 msg6) () () h a
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
            , update : () -> h -> Extended () a -> ( Extended () a, Cmd () )
            , view : () -> Html ()
            }
        , a4 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> h -> Extended () a -> ( Extended () a, Cmd () )
            , view : () -> Html ()
            }
        , a5 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> h -> Extended () a -> ( Extended () a, Cmd () )
            , view : () -> Html ()
            }
        , a6 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> h -> Extended () a -> ( Extended () a, Cmd () )
            , view : () -> Html ()
            }
        , a7 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> h -> Extended () a -> ( Extended () a, Cmd () )
            , view : () -> Html ()
            }
        , a8 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> h -> Extended () a -> ( Extended () a, Cmd () )
            , view : () -> Html ()
            }
        , a9 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> h -> Extended () a -> ( Extended () a, Cmd () )
            , view : () -> Html ()
            }
        , a10 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> h -> Extended () a -> ( Extended () a, Cmd () )
            , view : () -> Html ()
            }
        , a11 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> h -> Extended () a -> ( Extended () a, Cmd () )
            , view : () -> Html ()
            }
        , a12 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 () () () () () () () () () ()
            , toMsg : () -> Switch msg1 msg2 () () () () () () () () () ()
            , update : () -> h -> Extended () a -> ( Extended () a, Cmd () )
            , view : () -> Html ()
            }
        }
layout2 info1 info2 =
    { a1 = { init = info1.init, update = info1.update, view = info1.view, subscriptions = info1.subscriptions, toMsg = Opt1, toModel = Opt1 }
    , a2 = { init = info2.init, update = info2.update, view = info2.view, subscriptions = info2.subscriptions, toMsg = Opt2, toModel = Opt2 }
    , a3 = { init = always (save ()), update = always (always save), subscriptions = always Sub.none, view = always (text ""), toMsg = Opt3, toModel = Opt3 }
    , a4 = { init = always (save ()), update = always (always save), subscriptions = always Sub.none, view = always (text ""), toMsg = Opt4, toModel = Opt4 }
    , a5 = { init = always (save ()), update = always (always save), subscriptions = always Sub.none, view = always (text ""), toMsg = Opt5, toModel = Opt5 }
    , a6 = { init = always (save ()), update = always (always save), subscriptions = always Sub.none, view = always (text ""), toMsg = Opt6, toModel = Opt6 }
    , a7 = { init = always (save ()), update = always (always save), subscriptions = always Sub.none, view = always (text ""), toMsg = Opt7, toModel = Opt7 }
    , a8 = { init = always (save ()), update = always (always save), subscriptions = always Sub.none, view = always (text ""), toMsg = Opt8, toModel = Opt8 }
    , a9 = { init = always (save ()), update = always (always save), subscriptions = always Sub.none, view = always (text ""), toMsg = Opt9, toModel = Opt9 }
    , a10 = { init = always (save ()), update = always (always save), subscriptions = always Sub.none, view = always (text ""), toMsg = Opt10, toModel = Opt10 }
    , a11 = { init = always (save ()), update = always (always save), subscriptions = always Sub.none, view = always (text ""), toMsg = Opt11, toModel = Opt11 }
    , a12 = { init = always (save ()), update = always (always save), subscriptions = always Sub.none, view = always (text ""), toMsg = Opt12, toModel = Opt12 }
    }


layout6 :
    { init : init1, subscriptions : subs1, update : update1, view : view1 }
    -> { init : init2, subscriptions : subs2, update : update2, view : view2 }
    -> { init : init3, subscriptions : subs3, update : update3, view : view3 }
    -> { init : init4, subscriptions : subs4, update : update4, view : view4 }
    -> { init : init5, subscriptions : subs5, update : update5, view : view5 }
    -> { init : init6, subscriptions : subs6, update : update6, view : view6 }
    ->
        { a1 :
            { init : init1
            , subscriptions : subs1
            , toModel : a1 -> Switch a1 a2 a3 a4 a5 a6 () () () () () ()
            , toMsg : msg1 -> Switch msg1 msg2 msg3 msg4 msg5 msg6 () () () () () ()
            , update : update1
            , view : view1
            }
        , a2 :
            { init : init2
            , subscriptions : subs2
            , toModel : a2 -> Switch a1 a2 a3 a4 a5 a6 () () () () () ()
            , toMsg : msg2 -> Switch msg1 msg2 msg3 msg4 msg5 msg6 () () () () () ()
            , update : update2
            , view : view2
            }
        , a3 :
            { init : init3
            , subscriptions : subs3
            , toModel : a3 -> Switch a1 a2 a3 a4 a5 a6 () () () () () ()
            , toMsg : msg3 -> Switch msg1 msg2 msg3 msg4 msg5 msg6 () () () () () ()
            , update : update3
            , view : view3
            }
        , a4 :
            { init : init4
            , subscriptions : subs4
            , toModel : a4 -> Switch a1 a2 a3 a4 a5 a6 () () () () () ()
            , toMsg : msg4 -> Switch msg1 msg2 msg3 msg4 msg5 msg6 () () () () () ()
            , update : update4
            , view : view4
            }
        , a5 :
            { init : init5
            , subscriptions : subs5
            , toModel : a5 -> Switch a1 a2 a3 a4 a5 a6 () () () () () ()
            , toMsg : msg5 -> Switch msg1 msg2 msg3 msg4 msg5 msg6 () () () () () ()
            , update : update5
            , view : view5
            }
        , a6 :
            { init : init6
            , subscriptions : subs6
            , toModel : a6 -> Switch a1 a2 a3 a4 a5 a6 () () () () () ()
            , toMsg : msg6 -> Switch msg1 msg2 msg3 msg4 msg5 msg6 () () () () () ()
            , update : update6
            , view : view6
            }
        , a7 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 a3 a4 a5 a6 () () () () () ()
            , toMsg : () -> Switch msg1 msg2 msg3 msg4 msg5 msg6 () () () () () ()
            , update : () -> h -> Extended () a -> ( Extended () a, Cmd () )
            , view : () -> Html ()
            }
        , a8 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 a3 a4 a5 a6 () () () () () ()
            , toMsg : () -> Switch msg1 msg2 msg3 msg4 msg5 msg6 () () () () () ()
            , update : () -> h -> Extended () a -> ( Extended () a, Cmd () )
            , view : () -> Html ()
            }
        , a9 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 a3 a4 a5 a6 () () () () () ()
            , toMsg : () -> Switch msg1 msg2 msg3 msg4 msg5 msg6 () () () () () ()
            , update : () -> h -> Extended () a -> ( Extended () a, Cmd () )
            , view : () -> Html ()
            }
        , a10 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 a3 a4 a5 a6 () () () () () ()
            , toMsg : () -> Switch msg1 msg2 msg3 msg4 msg5 msg6 () () () () () ()
            , update : () -> h -> Extended () a -> ( Extended () a, Cmd () )
            , view : () -> Html ()
            }
        , a11 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 a3 a4 a5 a6 () () () () () ()
            , toMsg : () -> Switch msg1 msg2 msg3 msg4 msg5 msg6 () () () () () ()
            , update : () -> h -> Extended () a -> ( Extended () a, Cmd () )
            , view : () -> Html ()
            }
        , a12 :
            { init : {} -> ( (), Cmd () )
            , subscriptions : () -> Sub ()
            , toModel : () -> Switch a1 a2 a3 a4 a5 a6 () () () () () ()
            , toMsg : () -> Switch msg1 msg2 msg3 msg4 msg5 msg6 () () () () () ()
            , update : () -> h -> Extended () a -> ( Extended () a, Cmd () )
            , view : () -> Html ()
            }
        }
layout6 info1 info2 info3 info4 info5 info6 =
    { a1 = { init = info1.init, update = info1.update, view = info1.view, subscriptions = info1.subscriptions, toMsg = Opt1, toModel = Opt1 }
    , a2 = { init = info2.init, update = info2.update, view = info2.view, subscriptions = info2.subscriptions, toMsg = Opt2, toModel = Opt2 }
    , a3 = { init = info3.init, update = info3.update, view = info3.view, subscriptions = info3.subscriptions, toMsg = Opt3, toModel = Opt3 }
    , a4 = { init = info4.init, update = info4.update, view = info4.view, subscriptions = info4.subscriptions, toMsg = Opt4, toModel = Opt4 }
    , a5 = { init = info5.init, update = info5.update, view = info5.view, subscriptions = info5.subscriptions, toMsg = Opt5, toModel = Opt5 }
    , a6 = { init = info6.init, update = info6.update, view = info6.view, subscriptions = info6.subscriptions, toMsg = Opt6, toModel = Opt6 }
    , a7 = { init = always (save ()), update = always (always save), subscriptions = always Sub.none, view = always (text ""), toMsg = Opt7, toModel = Opt7 }
    , a8 = { init = always (save ()), update = always (always save), subscriptions = always Sub.none, view = always (text ""), toMsg = Opt8, toModel = Opt8 }
    , a9 = { init = always (save ()), update = always (always save), subscriptions = always Sub.none, view = always (text ""), toMsg = Opt9, toModel = Opt9 }
    , a10 = { init = always (save ()), update = always (always save), subscriptions = always Sub.none, view = always (text ""), toMsg = Opt10, toModel = Opt10 }
    , a11 = { init = always (save ()), update = always (always save), subscriptions = always Sub.none, view = always (text ""), toMsg = Opt11, toModel = Opt11 }
    , a12 = { init = always (save ()), update = always (always save), subscriptions = always Sub.none, view = always (text ""), toMsg = Opt12, toModel = Opt12 }
    }


label2 : (({ b | a1 : a } -> a) -> ({ b | a2 : c } -> c) -> e) -> e
label2 =
    Recipes.Switch.label2


label6 : (({ b | a1 : a } -> a) -> ({ b | a2 : c } -> c) -> ({ b | a3 : e } -> e) -> ({ b | a4 : g } -> g) -> ({ b | a5 : i } -> i) -> ({ b | a6 : k } -> k) -> m) -> m
label6 =
    Recipes.Switch.label6


type alias Item1 a b =
    Recipes.Switch.Item1 a b


type alias Item2 a b =
    Recipes.Switch.Item2 a b


type alias Item3 a b =
    Recipes.Switch.Item3 a b


type alias Item4 a b =
    Recipes.Switch.Item4 a b


type alias Item5 a b =
    Recipes.Switch.Item5 a b


type alias Item6 a b =
    Recipes.Switch.Item6 a b
