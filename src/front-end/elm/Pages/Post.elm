--------------------------------------------------


module Pages.Post exposing (Model, Msg, page)


--------------------------------------------------


import Html as H

import Types as T
import View as V


--------------------------------------------------


type alias Model =
  { postId : String }


--------------------------------------------------


type Msg
  = None


--------------------------------------------------


page : String -> T.Page Model Msg T.GlobalMsg
page postId =
  { init = init postId
  , update = update
  , view = view
  , subscriptions = subscriptions
  }


--------------------------------------------------


init : String -> T.Init Model Msg T.GlobalMsg
init postId =
  ( { postId = postId
    , ready = True
    , layoutClass = T.LC_Normal
    , seoTitle = "Post title"
    , seoDescription = "Post description"
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
    [ H.text "Post view"
    , V.link T.R_Home [] [ H.text "Go home" ]
    ]


--------------------------------------------------


subscriptions : T.Subscriptions Model Msg T.GlobalMsg
subscriptions _ =
  Sub.none


--------------------------------------------------
