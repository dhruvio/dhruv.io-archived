--------------------------------------------------


module View exposing (..)


--------------------------------------------------


import Html as H
import Html.Attributes as HA
import Html.Events as HE exposing (defaultOptions)
import Json.Decode as JD

import Types as T


--------------------------------------------------


link : T.Route -> List (H.Attribute (T.PageMsg msg T.GlobalMsg)) -> List (H.Html (T.PageMsg msg T.GlobalMsg)) -> H.Html (T.PageMsg msg T.GlobalMsg)
link route attributes children =
  H.a
    ((++)
      attributes
      [ HA.href (T.routeToString route)
      , HE.onWithOptions
          "click"
          { defaultOptions | preventDefault = True }
          (JD.succeed <| T.Right <| T.GM_Navigate route)
      ]
    )
    children


--------------------------------------------------
