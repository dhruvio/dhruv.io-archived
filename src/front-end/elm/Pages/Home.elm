--------------------------------------------------


module Pages.Home exposing (Model, Msg, page)

--------------------------------------------------

import Html as H
import Html.Attributes as HA
import Types as T
import View as V


--------------------------------------------------


type alias Model =
    { home : String }



--------------------------------------------------


type Msg
    = None



--------------------------------------------------


page : T.Page Model Msg T.GlobalMsg
page =
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }



--------------------------------------------------


init : T.Init Model Msg T.GlobalMsg
init =
    ( { home = "Home"
      , ready = True
      , layoutClass = T.LC_VerticallyCentered
      , seoTitle = "Dhruv Dang"
      , seoDescription = "Full stack software engineer, specializing in user interfaces and search. Available to hire on a contract basis."
      }
    , Cmd.none
    )



--------------------------------------------------


update : T.Update Model Msg T.GlobalMsg
update msg model =
    ( model, Cmd.none )



--------------------------------------------------


view : T.View Model Msg T.GlobalMsg
view _ =
    H.div
        [ HA.class "page page-home" ]
        [ viewPosts
        , H.div [] [ H.text "More posts coming soon." ]
        ]


viewPosts : H.Html (T.PageMsg Msg T.GlobalMsg)
viewPosts =
    H.ul
        [ HA.class "posts" ]
        [ H.li []
            [ V.pageLink (T.R_Post "seo-for-single-page-apps")
                []
                [ H.text "SEO for Single-Page-Apps using Elm and Node.js" ]
            ]
        ]



--------------------------------------------------


subscriptions : T.Subscriptions Model Msg T.GlobalMsg
subscriptions _ =
    Sub.none



--------------------------------------------------
