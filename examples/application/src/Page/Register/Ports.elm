port module Page.Register.Ports exposing (websocketIn, websocketOut)


port websocketIn : (String -> msg) -> Sub msg


port websocketOut : String -> Cmd msg
