--------------------------------------------------


module Pages.Post (Model, Msg, page) where


--------------------------------------------------


import Types as T
import Html as H


--------------------------------------------------


type alias Model =
  { postId : String }


--------------------------------------------------


type Msg
  = None


--------------------------------------------------


page : String -> T.Page Model Msg
page postId =
  { init = init postId
  , update = update
  , view = view
  , subscriptions = subscriptions
  }


--------------------------------------------------


init : String -> T.Init Model Msg
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


update : T.Update Model Msg
update msg model =
  (model, Cmd.none)


--------------------------------------------------


view : T.View Model Msg
view _ =
  H.text "Post view"


--------------------------------------------------


subscriptions : T.Subscriptions Model Msg
subscriptions =
  Sub.none


--------------------------------------------------
