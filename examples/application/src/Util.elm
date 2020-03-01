module Util exposing (..)

import Update.Pipeline exposing (using, when)
import Update.Pipeline.Extended exposing (Extended, lift)


choosing : (a -> Extended a c -> b) -> Extended a c -> b
choosing fun ( model, calls ) =
    fun model ( model, calls )
