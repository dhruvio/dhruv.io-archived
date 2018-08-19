--------------------------------------------------


module Pages.Home exposing (Model, Msg, page)


--------------------------------------------------


import Html as H

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
    , layoutClass = T.LC_Normal
    , seoTitle = "Home title"
    , seoDescription = "Home description"
    }
  , Cmd.none
  )


--------------------------------------------------


update : T.Update Model Msg T.GlobalMsg
update msg model =
  (model, Cmd.none)


--------------------------------------------------


view : T.View Model Msg T.GlobalMsg
view _ =
  H.div
    []
    [ H.text "Home view"
    , V.link (T.R_Post "123") [] [ H.text "Go to post" ]
    ]


--------------------------------------------------


subscriptions : T.Subscriptions Model Msg T.GlobalMsg
subscriptions _ =
  Sub.none


--------------------------------------------------
