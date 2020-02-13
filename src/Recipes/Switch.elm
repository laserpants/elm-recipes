module Recipes.Switch exposing (..)

import Html exposing (Html, text, span)
import Update.Pipeline exposing (save, andThen, map, mapCmd)


type Choice a1 a2 =
    Choice a1 a2


type Switch a1 a2 = 
    Switch (Maybe a1) (Maybe a2)


apply : 
    Choice (a1 -> b1) (a2 -> b2)
    -> Switch a1 a2 
    -> Switch b1 b2
apply (Choice f1 f2) (Switch a1 a2) =
    Switch (Maybe.map f1 a1) (Maybe.map f2 a2)


apply2 : 
    Choice (a1 -> b1 -> c1) (a2 -> b2 -> c2)
    -> Switch a1 a2 
    -> Switch b1 b2 
    -> Switch c1 c2
apply2 (Choice f1 f2) (Switch a1 a2) (Switch b1 b2) =
    Switch (Maybe.map2 f1 a1 b1) (Maybe.map2 f2 a2 b2)


s1 : a1 -> Switch a1 a2
s1 a1 =
    Switch (Just a1) Nothing


s2 : a2 -> Switch a1 a2
s2 a2 =
    Switch Nothing (Just a2)


toList : Switch a a -> List (Maybe a)
toList (Switch a1 a2) =
    [ a1, a2 ]


cToList : Choice a a -> List a
cToList (Choice a1 a2) =
    [ a1, a2 ]



switchUpdate updates msgs models =
    let 
        sw =
            models
                |> apply2 updates msgs
                |> apply (Choice (map s1 << mapCmd s1) (map s2 << mapCmd s2))
                --|> apply ( map s1 << mapCmd s1, map s2 << mapCmd s2 )
    in
    case sw of
        Switch (Just a1) _ ->
            a1

        Switch _ (Just a2) ->
            a2

        _ ->
            ( models, Cmd.none )


xxx choice default funs switch =
    switch
        |> apply funs
        |> apply choice
        |> toList
        |> List.map (Maybe.withDefault default)


switchSubscriptions subs =
    Sub.batch << xxx (Choice (Sub.map s1) (Sub.map s2)) Sub.none subs


switchView views =
    span [] << xxx (Choice (Html.map s1) (Html.map s2)) (text "") views


switchTo_ toMsg (Choice a1 a2) page =
    if a1.page == page then 
        a1.init
            |> mapCmd (toMsg << s1)
            |> map s1

    else
        a2.init
            |> mapCmd (toMsg << s2)
            |> map s2


switchUpdate_ toMsg (Choice a1 a2) msg model =
    model.switch
        |> switchUpdate (Choice a1.update a2.update) msg
        |> mapCmd toMsg
        |> andThen (\switch -> save { model | switch = switch })


switchSubscriptions_ toMsg (Choice a1 a2) =
    Sub.map toMsg << switchSubscriptions (Choice a1.subscriptions a2.subscriptions)


switchView_ toMsg (Choice a1 a2) =
    Html.map toMsg << switchView (Choice a1.view a2.view)
