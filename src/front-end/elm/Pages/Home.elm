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
      , seoDescription = "Full-stack TypeScript & JavaScript Consultant."
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
        [ viewPitch
        , viewPosts
        ]


viewPitch : H.Html (T.PageMsg Msg T.GlobalMsg)
viewPitch =
    H.section
        [ HA.class "section-pitch" ]
        [ H.h2 []
            [ V.responsiveLines
                [ [ H.text "Full-stack TypeScript & JavaScript Consultant." ]
                ]
            ]
        , V.responsiveLines
            [ [ H.text "Available to hire on a contract basis." ]
            , [ H.text "Reach me at "
              , H.a
                    [ HA.href "mailto:hi@dhruv.io" ]
                    [ H.text "hi@dhruv.io" ]
              , H.text "."
              ]
            ]
        ]


viewPosts : H.Html (T.PageMsg Msg T.GlobalMsg)
viewPosts =
    H.section
        [ HA.class "section-posts" ]
        [ H.h2 [ HA.class "section-heading" ] [ H.text "Posts." ]
        , H.ul
            [ HA.class "posts" ]
            [ H.li []
                [ V.pageLink (T.R_Post "seo-for-single-page-apps")
                    []
                    [ H.h3 [] [ H.text "SEO for Single-Page-Apps with Headless Chromium" ] ]
                ]
            ]
        ]



--------------------------------------------------


subscriptions : T.Subscriptions Model Msg T.GlobalMsg
subscriptions _ =
    Sub.none



--------------------------------------------------
