--------------------------------------------------


module Pages.Home (Model, Msg, page) where


--------------------------------------------------


import Types as T
import Html as H


--------------------------------------------------


type alias Model =
  { home : String }


--------------------------------------------------


type Msg
  = None


--------------------------------------------------


page : T.Page Model Msg
page =
  { init = init
  , update = update
  , view = view
  , subscriptions = subscriptions
  }


--------------------------------------------------


init : T.Init Model Msg
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


update : T.Update Model Msg
update msg model =
  (model, Cmd.none)


--------------------------------------------------


view : T.View Model Msg
view _ =
  H.text "Home view"


--------------------------------------------------


subscriptions : T.Subscriptions Model Msg
subscriptions =
  Sub.none


--------------------------------------------------
