module Page exposing (..)

import Data.Comment exposing (Comment)
import Data.Post exposing (Post)
import Data.Session exposing (Session)
import Data.User exposing (User)
import Html exposing (Html, text)
import Page.About
import Page.Home
import Page.Login
import Page.NewPost
import Page.Register
import Page.ShowPost
import Recipes.Switch exposing (Switch(..))
import Recipes.Switch.Extended as Switch exposing (Item1, Item2, Item3, Item4, Item5, Item6, Layout6, OneOf6, RunSwitch, index6, layout6, option6, runStack)
import Update.Pipeline exposing (save)
import Update.Pipeline.Extended exposing (Extended)


type alias Msg =
    OneOf6
        -- \
        Page.Home.Msg
        Page.NewPost.Msg
        Page.ShowPost.Msg
        Page.Login.Msg
        Page.Register.Msg
        Page.About.Msg


type alias Model =
    OneOf6
        -- \
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
    (msg2 -> msg1)
    -> Pages a
    -> RunSwitch (Pages a) (HasPageModel b) Model msg1 msg2
run =
    runStack .page insertAsPageIn


type alias Handlers a =
    { onAuthResponse : Maybe Session -> a
    , onPostAdded : Post -> a
    , onCommentCreated : Comment -> a
    , onRegistrationComplete : User -> a
    }


type alias Pages a =
    Layout6 (Handlers a)
        a
        -- \
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
    layout6
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


type alias Index a1 a2 a3 a4 a5 a6 =
    { homePage : a1
    , newPostPage : a2
    , showPostPage : a3
    , loginPage : a4
    , registerPage : a5
    , aboutPage : a6
    }


index :
    { homePage : Item1 a b
    , newPostPage : Item2 a b
    , showPostPage : Item3 a b
    , loginPage : Item4 a b
    , registerPage : Item5 a b
    , aboutPage : Item6 a b
    }
index =
    index6 Index


type alias Option =
    { isHomePage : Bool
    , isNewPostPage : Bool
    , isShowPostPage : Bool
    , isLoginPage : Bool
    , isRegisterPage : Bool
    , isAboutPage : Bool
    }


option : Model -> Option
option =
    option6 Option


subscriptions : Model -> Sub Msg
subscriptions =
    Switch.subscriptions pages


view : Model -> Html Msg
view =
    Switch.view pages
