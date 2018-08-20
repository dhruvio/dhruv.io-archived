----------------------------------------


port module Ports exposing (..)

----------------------------------------


type alias PageMetaData =
    { title : String
    , description : String
    }



----------------------------------------


port pageView : () -> Cmd msg


port windowScrollYTo : Float -> Cmd msg


port highlightCodeBlocks : () -> Cmd msg


port setPageMetaData : PageMetaData -> Cmd msg



----------------------------------------
