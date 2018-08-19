--------------------------------------------------


module Util exposing (..)


--------------------------------------------------


import Task


--------------------------------------------------


toCmd : msg -> Cmd msg
toCmd =
  Task.perform identity << Task.succeed


--------------------------------------------------


isJust : Maybe a -> Bool
isJust =
  Maybe.withDefault False << Maybe.map (always True)


--------------------------------------------------
