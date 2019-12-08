module Form.Error exposing (..)


type Error
    = MustNotBeEmpty
    | MustBeValidEmail
    | MustAgreeWithTerms
    | MustMatchPassword
    | PasswordTooShort
    | InvalidChar



-- TODO


toString _ =
    ""
