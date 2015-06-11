module Map.Svg.Events ( .. ) where

import Native.Map.Svg.Events
import Svg exposing (Attribute)
import Json.Decode exposing ( Decoder )
import VirtualDom
import Signal exposing ( Signal )

type alias Box = { x : Float, y : Float, w : Float, h : Float }

type alias EventInfo = { id    : String
                       , mouse : ( Int, Int )
                       , box   : Box
                       }

on : String -> Decoder a -> (a -> Signal.Message) -> Attribute
on =
    VirtualDom.on

empty : EventInfo
empty =
    { id    = ""
    , mouse = ( 0, 0 )
    , box   = makeBox ( 0, 0, 0, 0 )
    }

makeBox : ( Float, Float, Float, Float ) -> Box
makeBox =
    Native.Map.Svg.Events.makebox

messageOn : String -> (EventInfo -> Signal.Message) -> Attribute
messageOn name =
    on name decode

decode : Decoder EventInfo
decode =
    Native.Map.Svg.Events.decode

onMouseOver : (EventInfo -> Signal.Message) -> Attribute
onMouseOver =
    messageOn "mouseover"

onMouseOut : (EventInfo -> Signal.Message) -> Attribute
onMouseOut =
    messageOn "mouseover"
