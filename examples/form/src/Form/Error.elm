module Form.Error exposing (..)


type Error
    = MustNotBeEmpty
    | MustBeValidEmail
    | MustAcceptTerms
    | MustMatchPassword
    | PasswordTooShort


toString : Error -> String
toString error =
    case error of
        MustNotBeEmpty ->
            "This field is required"

        MustBeValidEmail ->
            "Not a valid email address"

        MustAcceptTerms ->
            "You must accept the terms to complete the registration"

        MustMatchPassword ->
            "Confirmation doesn’t match password"

        PasswordTooShort ->
            "The password must be at least eight characters long"
