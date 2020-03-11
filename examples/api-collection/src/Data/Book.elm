module Data.Book exposing (Book, decoder, encoder)

import Json.Decode as Json exposing (field)
import Json.Encode as Encode


type alias Book =
    { id : Maybe Int
    , title : String
    , author : String
    , synopsis : String
    }


decoder : Json.Decoder Book
decoder =
    Json.map4 Book
        (Json.maybe (field "id" Json.int))
        (field "title" Json.string)
        (field "author" Json.string)
        (field "synopsis" Json.string)


encoder : Book -> Json.Value
encoder { id, title, author, synopsis } =
    let
        maybeId =
            case id of
                Nothing ->
                    []

                Just theId ->
                    [ ( "id", Encode.int theId ) ]

        props =
            [ ( "title", Encode.string title )
            , ( "author", Encode.string author )
            , ( "synopsis", Encode.string synopsis )
            ]
    in
    Encode.object (maybeId ++ props)
