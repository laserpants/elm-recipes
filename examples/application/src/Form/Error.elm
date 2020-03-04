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
    case error of
        IsEmpty ->
            "This field is required"

        NotAnInt ->
            "This value must be an integer"

        NotAValidEmail ->
            "Not a valid email address"

        TermsNotAccepted ->
            "You must agree with the terms of service to complete the registration"

        DoesNotMatchPassword ->
            "Confirmation doesn’t match password"

        PasswordTooShort ->
            "The password must be at least eight characters long"

        UsernameTaken ->
            "This username is already taken"

        NotAlphanumeric ->
            "Only alphanumeric characters are allowed"
