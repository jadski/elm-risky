module Map ( .. ) where

import Native.Map
import Dict
import Debug
import String
import Maybe
import String exposing ( .. )
import Html
import Html exposing ( div, p, text, toElement )
import Html.Attributes exposing ( .. )
import Json.Encode
import Json.Decode
import Mouse
import Text
import Svg
import Svg.Attributes
import Svg.Events
import Svg exposing ( svg, g, defs, style, path, rect, set, animate, animateTransform )
import Graphics.Element exposing ( .. )
import Graphics.Element
import Graphics.Input
import Graphics.Collage as Collage
import Signal exposing ( .. )
import Time
import List
import Map.Svg.Events exposing ( EventInfo )
import Map.Svg.Events as MapEvents
import Map.World

type Mouse = Over EventInfo | Out EventInfo

emptyInfo = MapEvents.empty
emptyMouse = Out emptyInfo
{-

  This version implements the map using standard svg path nodes.
  Animations are applied to the map within the defs section, by creating nodes that reference path nodes to enact an animation.

  elm-svg does not support the x-link attribute (linking animation declarations to nodes), due to a bug in virtual dom
  (should use of setAttributeNS no setAttribute fo xlink refs). Virtual dom has been patched in this project only.

-}

activate : String -> Int
activate =
    Native.Map.activate

-- SVG
makeSvgPathNode : Map.World.Record -> Svg.Svg
makeSvgPathNode record = path [ Svg.svgNamespace
                              , Svg.Attributes.id     record.id
                              , Svg.Attributes.title  record.title
                              , Svg.Attributes.class  record.class
                              , Svg.Attributes.d      record.d
                              , Svg.Attributes.fill   "#c77"
                              , MapEvents.onMouseOver makeMessageOver
                              , MapEvents.onMouseOut  makeMessageOut
                              , attribute "xmlns:xlink" "http://www.w3.org/1999/xlink"
                              ] []

makeMessageOver : EventInfo -> Signal.Message
makeMessageOver xxxx =
    Signal.message mouseAddress ( Over xxxx )

makeMessageOut : EventInfo -> Signal.Message
makeMessageOut xxxx =
    Signal.message mouseAddress ( Out xxxx )

svgPaths =
    List.map makeSvgPathNode Map.World.records

-- MODEL
type alias Model = { title         : String
                   , mouseOver     : String
                   , mouse         : Mouse
                   , animationsOut : List String
                   }

initialModel : Model
initialModel = { title         = "no oink"
               , mouseOver     = ""
               , mouse         = emptyMouse
               , animationsOut = []
               }

centre model =
    case model.mouse of
      Over info -> let ords = info.box
                   in
                     ( ( ords.x + ( ords.w / 2 ) ),
                       ( ords.y + ( ords.h / 2 ) ) )

duration = "300ms"
scale = 1.2

translateMax ( x, y ) =
    ( x * ( scale - 1 ), y * ( scale - 1 ) )

negate ( x, y ) =
    ( -x, -y )

string ords
    = ( toString ( fst ords ) ) ++ "," ++ ( toString ( snd ords ) )

viewAnimations model =
    if | String.isEmpty model.mouseOver -> []
       | otherwise -> 
           let id = "#" ++ model.mouseOver
               midpoint = negate ( centre model )
               ignore = activate model.mouseOver
           in
             [ set     [ Svg.svgNamespace
                       , attribute                     "xmlns:xlink" "http://www.w3.org/1999/xlink"
                       , Svg.Attributes.xlinkHref      id
                       , Svg.Attributes.attributeType  "XML"
                       , Svg.Attributes.attributeName  "stroke"
                       , Svg.Attributes.to             "#822"
                       , Svg.Attributes.begin          "0s"
                       , Svg.Attributes.dur            duration
                       , Svg.Attributes.repeatCount    "indefinite" ][]

             , animate [ Svg.svgNamespace
                       , attribute                     "xmlns:xlink" "http://www.w3.org/1999/xlink"
                       , Svg.Attributes.xlinkHref      id
                       , Svg.Attributes.attributeType  "XML"
                       , Svg.Attributes.attributeName  "stroke-width"
                       , Svg.Attributes.from           "1"
                       , Svg.Attributes.to             (toString ( 1.5 * scale ) )
                       , Svg.Attributes.begin          "0s"
                       , Svg.Attributes.dur            duration
                       , Svg.Attributes.additive       "sum"
                       , Svg.Attributes.repeatCount    "indefinite" ][]

             , animate [ Svg.svgNamespace
                       , attribute                     "xmlns:xlink" "http://www.w3.org/1999/xlink"
                       , Svg.Attributes.xlinkHref      id
                       , Svg.Attributes.attributeType  "XML"
                       , Svg.Attributes.attributeName  "fill"
                       , Svg.Attributes.values         "#ff8; #f88; #f8f; #88f; #8ff; #8f8"
                       , Svg.Attributes.begin          "0s"
                       , Svg.Attributes.dur            duration
                       , Svg.Attributes.repeatCount    "indefinite" ][]
               {-
              , animateTransform [ Svg.svgNamespace
                               , attribute                     "xmlns:xlink" "http://www.w3.org/1999/xlink"
                               , Svg.Attributes.xlinkHref      id
                               , Svg.Attributes.attributeName  "transform"
                               , Svg.Attributes.attributeType  "XML"
                               , Svg.Attributes.type'          "translate"
                               --, Svg.Attributes.from           "0 0"
                               --, Svg.Attributes.to             "0 0"
                               , Svg.Attributes.values         ( "0 0;" ++ ( string ( translateMax midpoint ) ) ++ "; 0 0" )
                               --, Svg.Attributes.begin          "focusin +1s"
                               , Svg.Attributes.begin          "0s"
                               , Svg.Attributes.dur            duration
                               , Svg.Attributes.additive       "sum"
                               , Svg.Attributes.repeatCount    "indefinite" ][]
             , animateTransform [ Svg.svgNamespace
                               , attribute                     "xmlns:xlink" "http://www.w3.org/1999/xlink"
                               , Svg.Attributes.xlinkHref      id
                               , Svg.Attributes.attributeName  "transform"
                               , Svg.Attributes.attributeType  "XML"
                               , Svg.Attributes.type'          "scale"
                               , Svg.Attributes.values         ( "1.0;" ++ ( toString scale ) ++ ";1.0" )
                                --, Svg.Attributes.from           "1.0"
                                --, Svg.Attributes.to             ( toString scale )
                                --, Svg.Attributes.begin          "focusin +1s"
                                , Svg.Attributes.begin          "0s"
                                , Svg.Attributes.dur            duration
                                , Svg.Attributes.additive       "sum"
                                , Svg.Attributes.repeatCount    "indefinite" ][]
                -}
             ]

-- SIGNAL

mouseMailbox : Signal.Mailbox ( Mouse )
mouseMailbox = Signal.mailbox ( emptyMouse )
mouseAddress = mouseMailbox.address
mouseSignal  = mouseMailbox.signal

-- UPDATE

update : Mouse -> Model -> Model
update mouse model =
    let x = Debug.watch "mouse" mouse
        model2 = { model | mouse <- mouse }
    in
      case mouse of
        Over info ->
            if | info.id == model2.mouseOver -> model2
               | otherwise -> { model2 | mouseOver <- info.id, title <- info.id }
        Out info ->
            if | List.member info.id model2.animationsOut -> { model2 | mouseOver <- "", title <- "(the big sea)" }
               | otherwise -> { model2 | animationsOut  <- model2.animationsOut  ++ [ info.id ], mouseOver <- "" }
        _ ->
            { model2 | title <- "(OOINK)" }

model : Signal Model
model =
    Signal.foldp update initialModel mouseSignal

debugModelClasses model =
    List.map (\ record -> { class = record.class, name = record.title } ) ( Dict.values model.regions )

-- VIEW
view model =
    let y = Debug.watch "model.animationsOut" model.animationsOut
        x = Debug.watch "model.mouseOver" model.mouseOver  -- Debug.watch "classes" (debugModelClasses model)
    in
      flow down [ -- show model,
                 toElement 1000 1000 (
                                       div [ class "map-container"
                                           , Html.Attributes.style [ ( "display", "block" )
                                                                   , ( "visiblity", "visible" )
                                                                   , ( "font-size", "24px" ) ]
                                           ]
                                       [ p [] [ text ( model.title ) ]
                                       , div []
                                                 [
                                                  svg [ Svg.svgNamespace
                                                      , name "oink"
                                                      , attribute "width" "1000px"
                                                      , attribute "height" "1000px"
                                                      , class "world-map"
                                                      -- , attribute "xmlns" "http://www.w3.org/2000/svg"
                                                      , attribute "xmlns:xlink" "http://www.w3.org/1999/xlink"
                                                      ]
                                                  [ defs [ Svg.svgNamespace
                                                         , attribute "xmlns:xlink" "http://www.w3.org/1999/xlink"
                                                         ] ( viewAnimations model )
                                                  , g [ Svg.svgNamespace
                                                      , Svg.Attributes.id "group-map"
                                                      , attribute "xmlns:xlink" "http://www.w3.org/1999/xlink"
                                                      ] svgPaths
                                                  ]
                                                 ]
                                       ]
                                      )
                ]

main : Signal Element
main =
    Signal.map view model
