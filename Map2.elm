module Map2 ( .. ) where
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
import Svg exposing ( svg, g, defs, style, path, rect, animate, animateTransform )
import Graphics.Element exposing ( .. )
import Graphics.Element
import Graphics.Input
import Graphics.Collage as Collage
import Signal exposing ( .. )
import Time
import List
import Map.Svg.Events as MapEvents
import Map.World

emptyInfo = MapEvents.empty
{-

  This version implements the map using standard svg path nodes.
  Animations are applied to the map within the defs section, by creating nodes that reference path nodes to enact an animation.

  elm-svg does not support the x-link attribute (linking animation declarations to nodes), due to a bug in virtual dom
  (should use of setAttributeNS no setAttribute fo xlink refs). Virtual dom has been patched in this project only.

-}

-- SVG
makeSvgPathNode : Map.World.Record -> Svg.Svg
makeSvgPathNode record = path [ Svg.svgNamespace
                              , Svg.Attributes.id     record.id
                              , Svg.Attributes.title  record.title
                              , Svg.Attributes.class  record.class
                              , Svg.Attributes.d      record.d
                              , MapEvents.onMouseOver (  Signal.message mouseAddress )
                              , MapEvents.onMouseOut  ( Signal.message mouseAddress )
                              , attribute "xmlns:xlink" "http://www.w3.org/1999/xlink"
                              ] []


svgPaths =
    List.map makeSvgPathNode Map.World.records

-- MODEL
type alias Model = { title         : String
                   , mouseOver     : String
                   , mouseInfo     : EventInfo
                   , animationsOut : List String
                   }

initialModel : Model
initialModel = { title = "no oink"
               , mouseOver = ""
               , mouseInfo = emptyInfo
               , animationsOut = []
               }

viewAnimations model =
    if | String.isEmpty model.mouseOver -> []
       | otherwise -> [ animateTransform [ Svg.svgNamespace
                                         , attribute                     "xmlns:xlink" "http://www.w3.org/1999/xlink"
                                         , Svg.Attributes.xlinkHref      ( "#" ++ model.mouseOver )
                                         , Svg.Attributes.attributeName  "transform"
                                         , Svg.Attributes.attributeType  "XML"
                                         , Svg.Attributes.type'          "scale"
                                         , Svg.Attributes.from           "1.0"
                                         , Svg.Attributes.to             "1.5"
                                         --, Svg.Attributes.begin          "focusin +1s"
                                         , Svg.Attributes.begin          "0s"
                                         , Svg.Attributes.dur            "2000ms"
                                         , Svg.Attributes.additive       "sum"
                                         , Svg.Attributes.repeatCount    "indefinite" ][]
                      , animateTransform [ Svg.svgNamespace
                                         , attribute                     "xmlns:xlink" "http://www.w3.org/1999/xlink"
                                         , Svg.Attributes.xlinkHref      ( "#" ++ model.mouseOver )
                                         , Svg.Attributes.attributeName  "transform"
                                         , Svg.Attributes.attributeType  "XML"
                                         , Svg.Attributes.type'          "translate"
                                         , Svg.Attributes.from           "0"
                                         , Svg.Attributes.to             "-100"
                                         --, Svg.Attributes.begin          "focusin +1s"
                                         , Svg.Attributes.begin          "0s"
                                         , Svg.Attributes.dur            "2000ms"
                                         , Svg.Attributes.additive       "sum"
                                         , Svg.Attributes.repeatCount    "indefinite" ][]
                      ]

-- SIGNAL

type alias EventInfo = MapEvents.EventInfo
type Mouse = Over EventInfo | Out EventInfo


{-
mouseMailbox : Signal.Mailbox ( Mouse )
mouseMailbox = Signal.mailbox ( Out emptyInfo )
-}
mouseMailbox : Signal.Mailbox ( EventInfo )
mouseMailbox = Signal.mailbox ( emptyInfo )
mouseAddress = mouseMailbox.address
mouseSignal  = mouseMailbox.signal

-- UPDATE

--update : Mouse -> Model -> Model
update : EventInfo -> Model -> Model
update mouse model =
    let x = Debug.watch "mouse" mouse
        model2 = { model | mouseInfo <- mouse }
    in
      case mouse of
        emptyInfo ->
            { model2 | title <- "(nothing)" }
        info ->
            if | List.member info.id model2.animationsOut -> { model2 | mouseOver <- "" }
               | otherwise -> { model2 | animationsOut  <- model2.animationsOut  ++ [ info.id ], mouseOver <- "" }
{-
        Over info ->
            if | info.id == model2.mouseOver -> model2
               | otherwise -> { model2 | mouseOver <- info.id }
-}

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
      flow down [ show model
                , toElement 1000 1000 (
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
