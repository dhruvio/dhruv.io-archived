--------------------------------------------------


module Pages.Post exposing (Model, Msg, page)

--------------------------------------------------

import Html as H
import Html.Attributes as HA
import Http as Ht
import Json.Decode as JD
import Json.Decode.Pipeline as JDP
import Markdown as Ma
import Types as T
import Util as U


--------------------------------------------------


type alias Metadata =
    { title : String
    , description : String
    , author : String
    , datePublished : String
    , footer : String
    }


type alias Model =
    { body : Maybe String
    , metadata : Maybe Metadata
    }



--------------------------------------------------


type Msg
    = LoadBody (Result Ht.Error String)
    | LoadMetadata (Result Ht.Error Metadata)



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
init id =
    ( { body = Nothing
      , metadata = Nothing
      , ready = False
      , layoutClass = T.LC_Normal
      , headerClass = T.HC_Compact
      , seoTitle = "Post title"
      , seoDescription = "Post description"
      }
    , Cmd.map
        T.Left
        (Cmd.batch
            [ getBody id
            , getMetadata id
            ]
        )
    )


getBody : String -> Cmd Msg
getBody id =
    Ht.getString ("/data/posts/" ++ id ++ ".md")
        |> Ht.send LoadBody


getMetadata : String -> Cmd Msg
getMetadata id =
    Ht.get ("/data/posts/" ++ id ++ ".json") decodeMetadata
        |> Ht.send LoadMetadata


decodeMetadata : JD.Decoder Metadata
decodeMetadata =
    JDP.decode Metadata
        |> JDP.required "title" JD.string
        |> JDP.required "description" JD.string
        |> JDP.required "author" JD.string
        |> JDP.required "datePublished" JD.string
        |> JDP.required "footer" JD.string



--------------------------------------------------


update : T.Update Model Msg T.GlobalMsg
update msg model =
    case msg of
        LoadBody result ->
            case result of
                Ok body ->
                    let
                        postIsReady =
                            U.isJust model.metadata
                    in
                    ( { model
                        | body = Just body
                        , ready = postIsReady
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, goHome )

        LoadMetadata result ->
            case result of
                Ok metadata ->
                    let
                        postIsReady =
                            U.isJust model.body
                    in
                    ( { model
                        | metadata = Just metadata
                        , ready = postIsReady
                        , seoTitle = metadata.title ++ " by " ++ metadata.author
                        , seoDescription = metadata.description
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, goHome )


goHome : Cmd (T.PageMsg Msg T.GlobalMsg)
goHome =
    U.toCmd <| T.Right <| T.GM_Navigate T.R_Home



--------------------------------------------------


view : T.View Model Msg T.GlobalMsg
view { body, metadata } =
    let
        viewLoaded body_ metadata_ =
            H.article
                [ HA.class "page page-post" ]
                [ viewMetadata metadata_
                , viewBody body_
                , viewFooter metadata_.footer
                ]

        viewLoading =
            H.article [] [ H.text "Loading" ]
    in
    Maybe.map2 viewLoaded body metadata
        |> Maybe.withDefault viewLoading


viewMetadata : Metadata -> H.Html (T.PageMsg Msg T.GlobalMsg)
viewMetadata metadata =
    H.div
        [ HA.class "post-metadata" ]
        [ H.h2
            [ HA.class "post-title" ]
            [ H.text metadata.title ]
        , H.div
            [ HA.class "post-date" ]
            [ H.text <| "Published on " ++ metadata.datePublished ]
        ]


viewBody : String -> H.Html (T.PageMsg Msg T.GlobalMsg)
viewBody body =
    Ma.toHtml
        [ HA.class "post-body" ]
        body


viewFooter : String -> H.Html (T.PageMsg Msg T.GlobalMsg)
viewFooter footer =
    Ma.toHtml
        [ HA.class "post-footer" ]
        footer



--------------------------------------------------


subscriptions : T.Subscriptions Model Msg T.GlobalMsg
subscriptions _ =
    Sub.none



--------------------------------------------------
