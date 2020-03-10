module Route exposing (Route(..), parser)

import Url.Parser as Parser exposing ((</>), Parser, int, map, oneOf, s, top)


type Route
    = Home
    | NewPost
    | ShowPost Int
    | Login
    | Register
    | About


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map Home top
        , map NewPost (s "posts" </> s "new")
        , map ShowPost (s "posts" </> int)
        , map Login (s "login")
        , map Register (s "register")
        , map About (s "about")
        ]
