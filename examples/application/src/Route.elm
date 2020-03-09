module Route exposing (Route(..), parser)

import Url.Parser as Parser exposing ((</>), Parser, oneOf, top)


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
        [ Parser.map Home top
        , Parser.map NewPost (Parser.s "posts" </> Parser.s "new")
        , Parser.map ShowPost (Parser.s "posts" </> Parser.int)
        , Parser.map Login (Parser.s "login")
        , Parser.map Register (Parser.s "register")
        , Parser.map About (Parser.s "about")
        ]
