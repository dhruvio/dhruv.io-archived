--------------------------------------------------


module View exposing (..)

--------------------------------------------------

import Html as H
import Html.Attributes as HA
import Html.Events as HE exposing (defaultOptions)
import Json.Decode as JD
import Types as T


--------------------------------------------------


link : msg -> List (H.Attribute msg) -> List (H.Html msg) -> H.Html msg
link msg attributes children =
    H.a
        ((++)
            attributes
            [ HE.onWithOptions
                "click"
                { defaultOptions | preventDefault = True }
                (JD.succeed msg)
            ]
        )
        children


pageLink : T.Route -> List (H.Attribute (T.PageMsg msg T.GlobalMsg)) -> List (H.Html (T.PageMsg msg T.GlobalMsg)) -> H.Html (T.PageMsg msg T.GlobalMsg)
pageLink route attributes children =
    link
        (T.Right <| T.GM_Navigate route)
        [ HA.href (T.routeToString route) ]
        children



--------------------------------------------------
