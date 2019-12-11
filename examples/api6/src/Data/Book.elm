module Data.Book exposing (Book, decoder)

import Json.Decode as Json exposing (field)


type alias Book =
    { id : Int
    , title : String
    , author : String
    , synopsis : String
    }


decoder : Json.Decoder Book
decoder =
    Json.map4 Book
        (field "id" Json.int)
        (field "title" Json.string)
        (field "author" Json.string)
        (field "synopsis" Json.string)
