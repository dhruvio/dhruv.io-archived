--------------------------------------------------


module Types (..) where


--------------------------------------------------


import Html as H exposing (Html)
import UrlParser as UP exposing ((</>))
import Navigation as N

import Pages.Home as PHome
import Pages.Post as PPost


--------------------------------------------------


type alias RootModel =
  { initialized : Bool
  , activePage : Maybe (PageState RootMsg)
  , incomingPage : Maybe (PageState RootMsg)
  }


type RootMsg
  = RM_StartTransition Route
  | RM_CompleteTransition
  | RM_UpdateActivePage PageMsg
  | RM_UpdateIncomingPage PageMsg


--------------------------------------------------


type alias Init model msg =
  (PageModel model, Cmd msg)


type alias Update model msg =
  msg -> PageModel model -> (PageModel model, Cmd msg)


type alias View model msg =
  PageModel model -> H.Html msg


type alias Subscriptions model msg =
  PageModel model -> Sub msg


type alias Page model msg =
  { init : Init model msg
  , update : Update model msg
  , view : View model msg
  , subscriptions : Subscriptions model msg
  }


--------------------------------------------------


type alias PageModel a =
  { a
  | ready : Bool
  , layoutClass : LayoutClass
  , seoTitle : String
  , seoDescription : Description
  }


isPageModelReady : T.PageModel a -> Bool
isPageModelReady {ready} =
  ready


pageLayoutClassString : T.PageModel a -> String
pageLayoutClassString {layoutClass} =
  layoutClassToString layoutClass


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


routeToPage : Route -> Page model msg
routeToPage route =
  case route of
    R_Home ->
      PHome.page

    R_Post id_ ->
      PPost.page id_


--------------------------------------------------


type alias MapMsg childMsg parentMsg =
  childMsg -> parentMsg


type PageState rootMsg
  = PS_Home (Page PHome.Model PHome.Msg) (PageModel PHome.Model) (MapMsg PHome.Msg rootMsg)
  | PS_Post (Page PPost.Model PPost.Msg) (PageModel PPost.Model) (MapMsg PPost.Msg rootMsg)


type PageMsg
  = PM_Home PHome.Msg
  | PM_Post PPost.Msg


pageStateEquivalent : PageState rootMsg -> PageState rootMsg -> Bool
pageStateEquivalent a b =
  case (a, b) of
    (PS_Home _ _ _, PS_Home _ _ _) ->
      True

    (PS_Post _ _ _, PS_Post _ _ _) ->
      True

    _ ->
      False


pageStateEq : PageState rootMsg -> PageState rootMsg -> Bool
pageStateEq a b =
  case (a, b) of
    (PS_Home p s _, PS_Home p_ s_ _) ->
      p == p_ && s == s_

    (PS_Post p s _, PS_Post p_ s_ _) ->
      p == p_ && s == s_

    _ ->
      False


initPageState : Route -> (PageMsg -> rootMsg) -> (PageState rootMsg, Cmd rootMsg)
initPageState route toRootMsg =
  let
    page =
      routeToPage route

    genericInit : (msg -> PageMsg) -> (Page model msg -> model -> MapMsg msg rootMsg) -> (PageState rootMsg, Cmd rootMsg)
    genericInit toPageMsg toPageState =
      let
        mapMsg =
          toRootMsg << toPageMsg

        (model, cmd) =
          page.init
      in
        ( toPageState page model mapMsg
        , Cmd.map mapMsg cmd
        )
  in
    case route of
      R_Home ->
        genericInit PM_Home PS_Home

      R_Post _ ->
        genericInit PM_Post PS_Post


updatePageState : PageMsg -> PageState rootMsg -> (PageState rootMsg, Cmd rootMsg)
updatePageState msg state =
  case msg of
    PM_Home pageMsg ->
      case state of
        PS_Home page pageModel mapMsg ->
          let
            (pageModel_, pageCmd) =
              page.update pageMsg pageModel
          in
            ( PS_Home page pageModel_ mapMsg
            , Cmd.map mapMsg pageCmd
            )

        _ ->
          (state, Cmd.none)

    PM_Post pageMsg ->
      case state of
        PS_Post page pageModel mapMsg ->
          let
            (pageModel_, pageCmd) =
              page.update pageMsg pageModel
          in
            ( PS_Post page pageModel_ mapMsg
            , Cmd.map mapMsg pageCmd
            )

        _ ->
          (state, Cmd.none)


viewPageState : PageState rootMsg -> Html rootMsg
viewPageState state =
  case state of
    PS_Home page model mapMsg ->
      page.view model
        |> Html.map mapMsg

    PS_Post page model mapMsg ->
      page.view model
        |> Html.map mapMsg


subscriptionsPageState : PageState rootMsg -> Sub rootMsg
subscriptionsPageState state =
  case state of
    PS_Home page model mapMsg ->
      page.subscriptions model
        |> Sub.map mapMsg

    PS_Post page model mapMsg ->
      page.subscriptions model
        |> Sub.map mapMsg


replacePageStateMapMsg : (PageMsg -> rootMsg) -> PageState Never -> PageState rootMsg
changePageStateMapMsg f state =
  case state of
    PS_Home p m _ ->
      PS_Home p m (f << PM_Home)

    PS_Post p m _ ->
      PS_Post p m (f << PM_Post)


--TODO
--Might get type ambiguity error here
getPageStateModel : PageState rootMsg -> PageModel model
getPageStateModel state =
  PS_Home _ m _ -> m
  PS_Post_ m _ -> m


isPageStateReady : PageState rootMsg -> Bool
isPageStateReady =
  isPageModelReady << getPageStateModel


getPageStateLayoutClassString : PageState rootMsg -> Bool
getPageStateLayoutClassString =
  pageLayoutClassString << getPageStateModel


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
