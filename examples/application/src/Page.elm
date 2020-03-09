module Page exposing (Model, Msg, Pages, index, option, pages, run, subscriptions, view)

import Data.Comment exposing (Comment)
import Data.Post exposing (Post)
import Data.Session exposing (Session)
import Data.User exposing (User)
import Html exposing (Html, text)
import Page.About
import Page.Home
import Page.Login
import Page.NewPost
import Page.NotFound
import Page.Register
import Page.ShowPost
import Recipes.Switch exposing (Switch(..))
import Recipes.Switch.Extended as Switch exposing (Item1, Item2, Item3, Item4, Item5, Item6, Item7, Layout7, OneOf7, RunSwitch, index7, layout7, option7, runStack)
import Update.Pipeline exposing (save)
import Update.Pipeline.Extended exposing (Extended)


type alias Msg =
    OneOf7
        -- elm-format: do not remove line breaks
        Page.NotFound.Msg
        Page.Home.Msg
        Page.NewPost.Msg
        Page.ShowPost.Msg
        Page.Login.Msg
        Page.Register.Msg
        Page.About.Msg


type alias Model =
    OneOf7
        -- elm-format: do not remove line breaks
        Page.NotFound.Model
        Page.Home.Model
        Page.NewPost.Model
        Page.ShowPost.Model
        Page.Login.Model
        Page.Register.Model
        Page.About.Model


type alias HasPageModel a =
    { a | page : Model }


insertAsPageIn : HasPageModel a -> Model -> ( HasPageModel a, Cmd msg )
insertAsPageIn model page =
    save { model | page = page }


run :
    (Msg -> msg)
    -> Pages a
    -> RunSwitch (Pages a) (HasPageModel b) Model msg Msg
run =
    runStack .page insertAsPageIn


type alias Handlers a =
    { onAuthResponse : Maybe Session -> a
    , onPostAdded : Post -> a
    , onCommentCreated : Comment -> a
    , onRegistrationComplete : User -> a
    }


type alias Pages a =
    Layout7 a
        (Handlers a)
        -- elm-format: do not remove line breaks
        Page.NotFound.Model
        Page.NotFound.Msg
        ()
        Page.Home.Model
        Page.Home.Msg
        ()
        Page.NewPost.Model
        Page.NewPost.Msg
        ()
        Page.ShowPost.Model
        Page.ShowPost.Msg
        Int
        Page.Login.Model
        Page.Login.Msg
        ()
        Page.Register.Model
        Page.Register.Msg
        ()
        Page.About.Model
        Page.About.Msg
        ()


pages : Pages a
pages =
    layout7
        { init = Page.NotFound.init
        , update = Page.NotFound.update
        , subscriptions = Page.NotFound.subscriptions
        , view = Page.NotFound.view
        }
        { init = Page.Home.init
        , update = Page.Home.update
        , subscriptions = Page.Home.subscriptions
        , view = Page.Home.view
        }
        { init = Page.NewPost.init
        , update = Page.NewPost.update
        , subscriptions = Page.NewPost.subscriptions
        , view = Page.NewPost.view
        }
        { init = Page.ShowPost.init
        , update = Page.ShowPost.update
        , subscriptions = Page.ShowPost.subscriptions
        , view = Page.ShowPost.view
        }
        { init = Page.Login.init
        , update = Page.Login.update
        , subscriptions = Page.Login.subscriptions
        , view = Page.Login.view
        }
        { init = Page.Register.init
        , update = Page.Register.update
        , subscriptions = Page.Register.subscriptions
        , view = Page.Register.view
        }
        { init = Page.About.init
        , update = Page.About.update
        , subscriptions = Page.About.subscriptions
        , view = Page.About.view
        }


type alias Index a1 a2 a3 a4 a5 a6 a7 =
    { notFoundPage : a1
    , homePage : a2
    , newPostPage : a3
    , showPostPage : a4
    , loginPage : a5
    , registerPage : a6
    , aboutPage : a7
    }


index :
    { notFoundPage : Item1 a b
    , homePage : Item2 a b
    , newPostPage : Item3 a b
    , showPostPage : Item4 a b
    , loginPage : Item5 a b
    , registerPage : Item6 a b
    , aboutPage : Item7 a b
    }
index =
    index7 Index


type alias Option =
    { isNotFoundPage : Bool
    , isHomePage : Bool
    , isNewPostPage : Bool
    , isShowPostPage : Bool
    , isLoginPage : Bool
    , isRegisterPage : Bool
    , isAboutPage : Bool
    }


option : Model -> Option
option =
    option7 Option


subscriptions : Model -> Sub Msg
subscriptions =
    Switch.subscriptions pages


view : Model -> Html Msg
view =
    Switch.view pages
