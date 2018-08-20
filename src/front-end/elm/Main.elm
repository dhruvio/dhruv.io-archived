--------------------------------------------------


module Main exposing (main)

--------------------------------------------------

import Html as H
import Html.Attributes as HA
import Navigation as N
import Pages.Home as PHome
import Pages.Post as PPost
import Ports as P
import Types as T
import Util as U
import View as V


--------------------------------------------------


main : Program Never RootModel RootMsg
main =
    N.program
        (RM_StartTransition << T.locationToRoute)
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



--------------------------------------------------


init : N.Location -> ( RootModel, Cmd RootMsg )
init location =
    let
        route =
            T.locationToRoute location

        ( page, cmd ) =
            initPageState route RM_UpdateIncomingPage RM_Global

        pageIsReady =
            isPageStateReady page
    in
    ( { initialized = pageIsReady
      , activePage =
            if pageIsReady then
                Just page
            else
                Nothing
      , incomingPage =
            if pageIsReady then
                Nothing
            else
                Just page
      }
    , cmd
    )



--------------------------------------------------


update : RootMsg -> RootModel -> ( RootModel, Cmd RootMsg )
update msg model =
    case msg of
        RM_StartTransition route ->
            let
                ( page, cmd_ ) =
                    initPageState route RM_UpdateIncomingPage RM_Global

                cmd =
                    if isPageStateReady page then
                        Cmd.batch
                            [ cmd_
                            , U.toCmd RM_CompleteTransition
                            ]
                    else
                        cmd_
            in
            ( { model
                | incomingPage = Just page
              }
            , cmd
            )

        RM_CompleteTransition ->
            case model.incomingPage of
                Nothing ->
                    ( model, Cmd.none )

                Just page ->
                    ( { model
                        | initialized = True
                        , activePage = Just (replacePageStateMapMsg RM_UpdateActivePage RM_Global page)
                        , incomingPage = Nothing
                      }
                    , Cmd.batch
                        [ P.windowScrollYTo 0
                        , P.setPageMetaData (getPageMetaData page)

                        --, P.highlightCodeBlocks ()
                        --, P.pageView ()
                        ]
                    )

        RM_UpdateActivePage pageMsg ->
            updatePage
                pageMsg
                .activePage
                (\p m -> { m | activePage = p })
                model

        RM_UpdateIncomingPage pageMsg ->
            updatePage
                pageMsg
                .incomingPage
                (\p m -> { m | incomingPage = p })
                model

        RM_Global globalMsg ->
            case globalMsg of
                T.GM_Navigate route ->
                    ( model, N.newUrl (T.routeToString route) )


updatePage : PageStateMsg -> (RootModel -> Maybe PageState) -> (Maybe PageState -> RootModel -> RootModel) -> RootModel -> ( RootModel, Cmd RootMsg )
updatePage pageMsg getPageState setPageState model =
    let
        pageState =
            getPageState model

        ( pageState_, cmd_ ) =
            pageState
                |> Maybe.map (updatePageState pageMsg)
                |> Maybe.map (Tuple.mapFirst Just)
                |> Maybe.withDefault ( pageState, Cmd.none )

        pageIsReady =
            pageState_
                |> Maybe.map isPageStateReady
                |> Maybe.withDefault False

        cmd =
            Cmd.batch
                [ cmd_
                , if pageIsReady && isLoading model then
                    U.toCmd RM_CompleteTransition
                  else
                    Cmd.none
                ]
    in
    ( setPageState pageState_ model
    , cmd
    )


isInitialized : RootModel -> Bool
isInitialized { initialized } =
    initialized


isTransitioning : RootModel -> Bool
isTransitioning { incomingPage } =
    U.isJust incomingPage


isLoading : RootModel -> Bool
isLoading model =
    not (isInitialized model) || isTransitioning model



--------------------------------------------------


view : RootModel -> H.Html RootMsg
view model =
    let
        layoutClassString =
            model.activePage
                |> Maybe.map getPageStateLayoutClassString
                |> Maybe.withDefault (T.layoutClassToString T.LC_Normal)
    in
    H.main_
        [ HA.class layoutClassString
        , HA.class <|
            if isLoading model then
                "loading"
            else
                "loaded"
        ]
        [ viewHeader
        , viewPage model.activePage
        , viewScreen
        ]


viewHeader : H.Html RootMsg
viewHeader =
    H.header
        []
        [ H.h1 []
            [ V.link
                (RM_Global <| T.GM_Navigate T.R_Home)
                [ HA.href "/" ]
                [ H.text "Dhruv Dang." ]
            ]
        , H.p [] [ H.text "Full stack software engineer, specializing in user interfaces and search." ]
        , H.p [] [ H.text "Previously at Apple, Deutsche Bank, Change.org, and Symphony." ]
        , H.p []
            [ H.text "Available to hire on a contract basis. Reach me at "
            , H.a
                [ HA.href "mailto:hi@dhruv.io" ]
                [ H.text "hi@dhruv.io" ]
            , H.text "."
            ]
        ]


viewPage : Maybe PageState -> H.Html RootMsg
viewPage page =
    page
        |> Maybe.map viewPageState
        |> Maybe.withDefault (H.div [ HA.class "empty" ] [])


viewScreen : H.Html RootMsg
viewScreen =
    H.div [ HA.id "screen" ] []



--------------------------------------------------


subscriptions : RootModel -> Sub RootMsg
subscriptions { activePage, incomingPage } =
    let
        getPageSubs =
            Maybe.withDefault Sub.none << Maybe.map subscriptionsPageState
    in
    Sub.batch
        [ getPageSubs activePage
        , getPageSubs incomingPage
        ]



--------------------------------------------------


type alias RootModel =
    { initialized : Bool
    , activePage : Maybe PageState
    , incomingPage : Maybe PageState
    }


type RootMsg
    = RM_StartTransition T.Route
    | RM_CompleteTransition
    | RM_UpdateActivePage PageStateMsg
    | RM_UpdateIncomingPage PageStateMsg
    | RM_Global T.GlobalMsg



--------------------------------------------------


type PageState
    = PS_Home (T.Page PHome.Model PHome.Msg T.GlobalMsg) (T.PageModel PHome.Model) (T.MapMsg PHome.Msg RootMsg T.GlobalMsg)
    | PS_Post (T.Page PPost.Model PPost.Msg T.GlobalMsg) (T.PageModel PPost.Model) (T.MapMsg PPost.Msg RootMsg T.GlobalMsg)


type PageStateMsg
    = PM_Home PHome.Msg
    | PM_Post PPost.Msg


pageStateEquivalent : PageState -> PageState -> Bool
pageStateEquivalent a b =
    case ( a, b ) of
        ( PS_Home _ _ _, PS_Home _ _ _ ) ->
            True

        ( PS_Post _ _ _, PS_Post _ _ _ ) ->
            True

        _ ->
            False


pageStateEq : PageState -> PageState -> Bool
pageStateEq a b =
    case ( a, b ) of
        ( PS_Home p s _, PS_Home p_ s_ _ ) ->
            p == p_ && s == s_

        ( PS_Post p s _, PS_Post p_ s_ _ ) ->
            p == p_ && s == s_

        _ ->
            False


initPageState : T.Route -> (PageStateMsg -> RootMsg) -> (T.GlobalMsg -> RootMsg) -> ( PageState, Cmd RootMsg )
initPageState route pageStateToRootMsg globalToRootMsg =
    let
        genericInit : T.Page model msg T.GlobalMsg -> (msg -> PageStateMsg) -> (T.Page model msg T.GlobalMsg -> T.PageModel model -> T.MapMsg msg RootMsg T.GlobalMsg -> PageState) -> ( PageState, Cmd RootMsg )
        genericInit page toPageStateMsg toPageState =
            let
                mapMsg =
                    createMapMsg toPageStateMsg pageStateToRootMsg globalToRootMsg

                ( model, cmd ) =
                    page.init
            in
            ( toPageState page model mapMsg
            , Cmd.map mapMsg cmd
            )
    in
    case route of
        T.R_Home ->
            genericInit PHome.page PM_Home PS_Home

        T.R_Post id ->
            genericInit (PPost.page id) PM_Post PS_Post


updatePageState : PageStateMsg -> PageState -> ( PageState, Cmd RootMsg )
updatePageState msg state =
    case msg of
        PM_Home pageMsg ->
            case state of
                PS_Home page pageModel mapMsg ->
                    let
                        ( pageModel_, pageCmd ) =
                            page.update pageMsg pageModel
                    in
                    ( PS_Home page pageModel_ mapMsg
                    , Cmd.map mapMsg pageCmd
                    )

                _ ->
                    ( state, Cmd.none )

        PM_Post pageMsg ->
            case state of
                PS_Post page pageModel mapMsg ->
                    let
                        ( pageModel_, pageCmd ) =
                            page.update pageMsg pageModel
                    in
                    ( PS_Post page pageModel_ mapMsg
                    , Cmd.map mapMsg pageCmd
                    )

                _ ->
                    ( state, Cmd.none )


viewPageState : PageState -> H.Html RootMsg
viewPageState state =
    case state of
        PS_Home page model mapMsg ->
            page.view model
                |> H.map mapMsg

        PS_Post page model mapMsg ->
            page.view model
                |> H.map mapMsg


subscriptionsPageState : PageState -> Sub RootMsg
subscriptionsPageState state =
    case state of
        PS_Home page model mapMsg ->
            page.subscriptions model
                |> Sub.map mapMsg

        PS_Post page model mapMsg ->
            page.subscriptions model
                |> Sub.map mapMsg


createMapMsg : (msg -> PageStateMsg) -> (PageStateMsg -> RootMsg) -> (T.GlobalMsg -> RootMsg) -> T.PageMsg msg T.GlobalMsg -> RootMsg
createMapMsg toPageStateMsg pageStateToRootMsg globalToRootMsg msg =
    case msg of
        T.Left pageMsg ->
            pageMsg
                |> toPageStateMsg
                |> pageStateToRootMsg

        T.Right globalMsg ->
            globalToRootMsg globalMsg


replacePageStateMapMsg : (PageStateMsg -> RootMsg) -> (T.GlobalMsg -> RootMsg) -> PageState -> PageState
replacePageStateMapMsg pageStateToRootMsg globalToRootMsg state =
    case state of
        PS_Home p m _ ->
            PS_Home p m (createMapMsg PM_Home pageStateToRootMsg globalToRootMsg)

        PS_Post p m _ ->
            PS_Post p m (createMapMsg PM_Post pageStateToRootMsg globalToRootMsg)


isPageStateReady : PageState -> Bool
isPageStateReady state =
    case state of
        PS_Home _ m _ ->
            T.isPageModelReady m

        PS_Post _ m _ ->
            T.isPageModelReady m


getPageStateLayoutClassString : PageState -> String
getPageStateLayoutClassString state =
    case state of
        PS_Home _ m _ ->
            T.pageLayoutClassString m

        PS_Post _ m _ ->
            T.pageLayoutClassString m


getPageMetaData : PageState -> P.PageMetaData
getPageMetaData state =
    case state of
        PS_Home _ m _ ->
            { title = m.seoTitle
            , description = m.seoDescription
            }

        PS_Post _ m _ ->
            { title = m.seoTitle
            , description = m.seoDescription
            }



--------------------------------------------------
