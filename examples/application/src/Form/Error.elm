module Form.Error exposing (..)


type Error
    = IsEmpty
    | NotAnInt
    | NotAValidEmail
    | TermsNotAccepted
    | DoesNotMatchPassword
    | PasswordTooShort
    | UsernameTaken
    | NotAlphanumeric


toString : Error -> String
toString error =
    ""
