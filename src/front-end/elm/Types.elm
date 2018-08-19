--------------------------------------------------


module Types exposing (..)


--------------------------------------------------


import Html as H exposing (Html)
import UrlParser as UP exposing ((</>))
import Navigation as N


--------------------------------------------------


type GlobalMsg
  = GM_Navigate Route


--------------------------------------------------


type Route
  = R_Home
  | R_Post String


routeEq : Route -> Route -> Bool
routeEq a b =
  case (a, b) of
    (R_Home, R_Home) ->
      True

    (R_Post c, R_Post d) ->
      c == d

    _ ->
      False


router : UP.Parser (Route -> a) a
router =
  UP.oneOf
    [ UP.map R_Home UP.top
    , UP.map R_Post (UP.s "posts" </> UP.string)
    ]


locationToRoute : N.Location -> Route
locationToRoute location =
  case UP.parsePath router location of
    Just route ->
      route

    Nothing ->
      R_Home


routeToString : Route -> String
routeToString route =
  case route of
    R_Home ->
      "/"

    R_Post id ->
      "/posts/" ++ id


--------------------------------------------------


type Either a b
  = Left a
  | Right b


--------------------------------------------------


type alias PageModel a =
  { a
  | ready : Bool
  , layoutClass : LayoutClass
  , seoTitle : String
  , seoDescription : String
  }


isPageModelReady : PageModel a -> Bool
isPageModelReady {ready} =
  ready


pageLayoutClassString : PageModel a -> String
pageLayoutClassString {layoutClass} =
  layoutClassToString layoutClass


--------------------------------------------------


type alias PageMsg msg globalMsg =
  Either msg globalMsg


--------------------------------------------------


type alias Init model msg globalMsg =
  (PageModel model, Cmd (PageMsg msg globalMsg))


type alias Update model msg globalMsg =
  msg -> PageModel model -> (PageModel model, Cmd (PageMsg msg globalMsg))


type alias View model msg globalMsg =
  PageModel model -> H.Html (PageMsg msg globalMsg) 


type alias Subscriptions model msg globalMsg =
  PageModel model -> Sub (PageMsg msg globalMsg) 


type alias Page model msg globalMsg =
  { init : Init model msg globalMsg
  , update : Update model msg globalMsg
  , view : View model msg globalMsg
  , subscriptions : Subscriptions model msg globalMsg
  }


type alias MapMsg childMsg parentMsg globalMsg =
  PageMsg childMsg globalMsg -> parentMsg


--------------------------------------------------


type LayoutClass
  = LC_Normal
  | LC_VerticallyCentered


layoutClassToString : LayoutClass -> String
layoutClassToString lc =
  case lc of
    LC_Normal ->
      "layout-normal"

    LC_VerticallyCentered ->
      "layout-vertically-centered"


--------------------------------------------------
