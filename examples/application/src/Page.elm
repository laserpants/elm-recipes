module Page exposing (..)

import Html exposing (Html)
import Page.About
import Page.Home
import Page.Login
import Page.NewPost
import Page.Register
import Page.ShowPost
import Recipes.Switch.Extended as Switch exposing (OneOf6, Layout6, RunSwitch, runStack)
import Update.Pipeline exposing (save)
import Update.Pipeline.Extended exposing (Extended)


type Page
    = NotFoundPage
    | HomePage
    | NewPostPage
    | ShowPostPage
    | LoginPage
    | RegisterPage
    | AboutPage


type alias Msg =
    OneOf6 Page.Home.Msg Page.NewPost.Msg Page.ShowPost.Msg Page.Login.Msg Page.Register.Msg Page.About.Msg


type alias Model =
    OneOf6 Page.Home.Model Page.NewPost.Model Page.ShowPost.Model Page.Login.Model Page.Register.Model Page.About.Model


type alias HasPageModel b =
    { b | page : Model }


insertAsPageIn : HasPageModel b -> Model -> ( HasPageModel b, Cmd msg )
insertAsPageIn model page =
    save { model | page = page }


type alias Info a =
    Layout6 Page {} Page.Home.Model Page.Home.Msg Page.NewPost.Model Page.NewPost.Msg Page.ShowPost.Model Page.ShowPost.Msg Page.Login.Model Page.Login.Msg Page.Register.Model Page.Register.Msg Page.About.Model Page.About.Msg a


run : (msg2 -> msg1) -> Info a -> RunSwitch (Info a) (HasPageModel b) Model msg1 msg2
run =
    runStack .page insertAsPageIn


pages : Info a
pages =
    let
        homePage =
            { init = Page.Home.init
            , update = Page.Home.update
            , subscriptions = Page.Home.subscriptions
            , view = Page.Home.view
            }

        newPostPage =
            { init = Page.NewPost.init
            , update = Page.NewPost.update
            , subscriptions = Page.NewPost.subscriptions
            , view = Page.NewPost.view
            }

        showPostPage =
            { init = Page.ShowPost.init
            , update = Page.ShowPost.update
            , subscriptions = Page.ShowPost.subscriptions
            , view = Page.ShowPost.view
            }

        loginPage =
            { init = Page.Login.init
            , update = Page.Login.update
            , subscriptions = Page.Login.subscriptions
            , view = Page.Login.view
            }

        registerPage =
            { init = Page.Register.init
            , update = Page.Register.update
            , subscriptions = Page.Register.subscriptions
            , view = Page.Register.view
            }

        aboutPage =
            { init = Page.About.init
            , update = Page.About.update
            , subscriptions = Page.About.subscriptions
            , view = Page.About.view
            }
    in
    Switch.layout6
        ( HomePage, homePage )
        ( NewPostPage, newPostPage )
        ( ShowPostPage, showPostPage )
        ( LoginPage, loginPage )
        ( RegisterPage, registerPage )
        ( AboutPage, aboutPage )



init : Page -> ( Model, Cmd Msg )
init page =
    Switch.init page {} pages


subscriptions : Model -> Sub Msg
subscriptions =
    Switch.subscriptions pages


view : Model -> Html Msg
view =
    Switch.view pages
