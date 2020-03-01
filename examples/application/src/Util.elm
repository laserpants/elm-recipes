module Util exposing (..)

import Update.Pipeline exposing (when, using)
import Update.Pipeline.Extended exposing (Extended, lift)


liftWhen :
    Bool
    -> (a -> ( a, Cmd msg ))
    -> Extended a c
    -> ( Extended a c, Cmd msg )
liftWhen cond =
    when cond << lift


extendedUsing : (a -> Extended a c -> b) -> Extended a c -> b
extendedUsing fun ( model, calls ) =
    fun model ( model, calls )
