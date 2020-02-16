module Recipes.Switch exposing (..)

import Update.Pipeline exposing (save, map, mapCmd)
import Html exposing (Html, text)


type Switch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 
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


type alias OneOf2_ a1 a2 =
    Switch_ a1 a2 () () () () () () () () () () 


type alias OneOf3_ a1 a2 a3 =
    Switch_ a1 a2 a3 () () () () () () () () () 


type alias OneOf4_ a1 a2 a3 a4 =
    Switch_ a1 a2 a3 a4 () () () () () () () () 


type alias OneOf5_ a1 a2 a3 a4 a5 =
    Switch_ a1 a2 a3 a4 a5 () () () () () () () 


type alias OneOf6_ a1 a2 a3 a4 a5 a6 =
    Switch_ a1 a2 a3 a4 a5 a6 () () () () () () 


type alias OneOf7_ a1 a2 a3 a4 a5 a6 a7 =
    Switch_ a1 a2 a3 a4 a5 a6 a7 () () () () () 


type alias OneOf8_ a1 a2 a3 a4 a5 a6 a7 a8 =
    Switch_ a1 a2 a3 a4 a5 a6 a7 a8 () () () () 


type alias OneOf9_ a1 a2 a3 a4 a5 a6 a7 a8 a9 =
    Switch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 () () () 


type alias OneOf10_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 =
    Switch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 () () 


type alias OneOf11_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 =
    Switch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 () 


type alias OneOf12_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 =
    Switch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12


type alias HasSwitch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a =
    { a | switch : Switch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 }


insertAsSwitchIn_ :
    HasSwitch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a
    -> Switch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
    -> ( HasSwitch_ a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a, Cmd msg )
insertAsSwitchIn_ model switch =
    save { model | switch = switch }


init_ opt arg =
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

        Opt5 a5 ->
            appl Opt5 Opt5 a5

        Opt6 a6 ->
            appl Opt6 Opt6 a6

        Opt7 a7 ->
            appl Opt7 Opt7 a7

        Opt8 a8 ->
            appl Opt8 Opt8 a8

        Opt9 a9 ->
            appl Opt9 Opt9 a9

        Opt10 a10 ->
            appl Opt10 Opt10 a10

        Opt11 a11 ->
            appl Opt11 Opt11 a11

        Opt12 a12 ->
            appl Opt12 Opt12 a12

        Miss ->
            save Miss


subscriptions_ { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 } switch =
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


view_ { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 } switch =
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
