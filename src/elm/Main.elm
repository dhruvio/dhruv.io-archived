--------------------------------------------------


module Main (main) where


--------------------------------------------------


import Html as H
import Html.Attributes as HA
import Navigation as N
import Types as T


--------------------------------------------------


main : Program Never T.RootModel T.RootMsg
main =
  N.program
    (T.RM_StartTransition << T.locationToRoute)
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }


--------------------------------------------------


init : N.Location -> T.RootModel
init location =
  let
    route =
      T.locationToRoute location
    
    (page, cmd) =
      T.initPageState route T.RM_UpdateIncomingPage
  in
    ( { initialized = False
      , activePage = Nothing
      , incomingPage = Just page
      }
    , cmd
    )


--------------------------------------------------


update : T.RootMsg -> T.RootModel -> (T.RootModel, Cmd T.RootMsg)
update msg model =
  case msg of
    T.RM_StartTransition route ->
      let
        (page, cmd_) =
          T.initPageState route T.RM_UpdateIncomingPage

        cmd =
          if pageIsReady page then
            Cmd.batch
              [ cmd_
              , U.toCmd T.RM_CompleteTransition
              ]
          else
            cmd_
      in
        ( { model
          | initialized = initialized
          , incomingPage = Just page
          }
        , cmd
        )
        
    T.RM_CompleteTransition ->
      case model.incomingPage of
        Nothing ->
          (model, Cmd.none)

        (Just page) ->
          ( { model
            | initialized = True
            , activePage = Just (T.replacePageStateMapMsg T.RM_UpdateActivePage page)
            , incomingPage = Nothing
            }
          , Cmd.none
          )

    T.RM_UpdateActivePage pageMsg ->
      updatePage
        pageMsg
        .activePage
        (\p m -> { m | activePage = p })
        model

    T.RM_UpdateIncomingPage pageMsg ->
      updatePage
        pageMsg
        .incomingPage
        (\p m -> { m | incomingPage = p })
        model


updatePage : T.PageMsg -> (T.RootModel -> Maybe (T.PageState T.RootMsg)) -> (Maybe (T.PageState T.RootMsg) -> T.RootModel -> T.RootModel) -> T.RootModel -> (T.RootModel, Cmd T.RootMsg)
updatePage pageMsg getPageState setPageState model =
  let
    pageState =
      getPageState model

    (pageState_, cmd_) =
      pageState
        |> Maybe.map (T.updatePageState pageMsg) 
        |> Maybe.map (Tuple.mapFirst Just)
        |> Maybe.withDefault (pageState, Cmd.none)

    cmd =
      Cmd.batch
        [ cmd_
        , if T.isPageStateReady pageState && isLoading model then
            U.toCmd T.RM_CompleteTransition
          else
            Cmd.none
        ]
  in
    ( setPageState pageModel_ model
    , cmd
    )


isInitialized : Model -> Bool
isTransitioning {initialized} =
  initialized


isTransitioning : Model -> Bool
isTransitioning {incomingPage} =
  U.isJust incomingPage


isLoading : Model -> Bool
isLoading model =
  not (isInitialized model) || isTransitioning model


--------------------------------------------------


view : T.RootModel -> H.Html T.RootMsg
view model =
  H.main
    [ HA.className <| T.getPageStateLayoutClassString model.activePage ]
    [ if isLoading model then H.text "Loading" else H.text "Loaded"
    , T.viewPageState model.activePage
    ]


viewHeader : H.Html T.RootMsg
viewHeader =
  H.div [] []


--------------------------------------------------


subscriptions : T.RootModel -> Sub T.RootMsg
subscriptions {activePage, incomingPage} =
  let
    getPageSubs =
      Maybe.withDefault Sub.none << Maybe.map T.subscriptionsPageState
  in
    Sub.batch
      [ getPageSubs activePage
      , getPageSubs incomingPage
      ]


--------------------------------------------------
