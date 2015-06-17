module Map ( .. ) where

import Native.Map

import Debug
import String
import Html exposing ( div, p, text, toElement )
import Html.Attributes exposing ( attribute, class, name )
import Svg exposing ( Svg, svg, g, defs, style, path, rect, set, animate, animateTransform )
import Svg.Attributes
import Graphics.Element exposing ( .. )
import Signal exposing ( .. )
import Map.Svg
import Map.Svg.Events exposing ( EventInfo )
import Map.Svg.Events as MapEvents
import Map.World
{-

  This version implements the map using standard svg path nodes.
  Animations are applied to the map within the defs section, by creating nodes that reference path nodes to enact an animation.

  elm-svg does not support the x-link attribute (linking animation declarations to nodes), due to a bug in virtual dom
  (should use of setAttributeNS no setAttribute fo xlink refs). Virtual dom has been patched in this project only.

-}


{-

  Switches on mouse over and out hovering animations.

  Hover is implemented by by setting animation element(s) href's to point at the currently hovering element.

  Eg. hoverEnable "elementClass" "animationId"

  elementClass : css class descriptor of all elements to be monitored
  animationId  : animation element whose href should be updated on mouseover to the current element
                 This can be an svg group <g> element in order to use multiple effects

-}
hoverEnable : String -> String -> Int
hoverEnable elementClass animationClass =
    Native.Map.hoverEnable elementClass animationClass

{-

  Switches off mouse over and out animations.

  Eg. hoverDisable elementClass

  elementClass : css class descriptor of all elements to be monitored

-}
hoverDisable : String -> Int
hoverDisable =
    Native.Map.hoverDisable

-- MODEL
type Mouse = Over EventInfo | Out EventInfo

--type alias Node = ( List Svg -> Svg )
type alias Node = Svg

type alias Model = { title         : String
                   , mouseOver     : String
                   , mouse         : Mouse
                   , animationsOut : List String
                   , lookup        : List ( String, Node )
                   , renderings    : Int
                   }

emptyInfo = MapEvents.empty
emptyMouse = Out emptyInfo

default : Model
default = { title         = "no oink"
          , mouseOver     = ""
          , mouse         = emptyMouse
          , animationsOut = []
          , lookup        = svgPaths
          , renderings    = 0
          }

mouseMailbox : Signal.Mailbox ( Mouse )
mouseMailbox = Signal.mailbox ( emptyMouse )
mouseAddress = mouseMailbox.address
mouseSignal  = mouseMailbox.signal

node : Map.World.Record -> Node
node record =
    path [ Svg.svgNamespace
         , Svg.Attributes.id     record.id
         , Svg.Attributes.title  record.title
         , Svg.Attributes.class  "land-class"
         , Svg.Attributes.d      record.d
         , Svg.Attributes.fill   "#c99"
         , MapEvents.onMouseOver makeMessageOver
         , MapEvents.onMouseOut  makeMessageOut
         , attribute "xmlns:xlink" "http://www.w3.org/1999/xlink"
         ] []

-- UPDATE
-- SVG
mapId : String
mapId =
    "map-root"

svgPath : Map.World.Record -> ( String, Node )
svgPath record = ( record.id, node record )

svgPaths =
    List.map svgPath Map.World.records

svgNodes =
    List.map node Map.World.records

makeMessageOver : EventInfo -> Signal.Message
makeMessageOver xxxx =
    Signal.message mouseAddress ( Over xxxx )

makeMessageOut : EventInfo -> Signal.Message
makeMessageOut xxxx =
    Signal.message mouseAddress ( Out xxxx )

duration = "300ms"
scale = 1.2

centre model =
    case model.mouse of
      Over info -> let ords = info.box
                   in
                     ( ( ords.x + ( ords.w / 2 ) ),
                       ( ords.y + ( ords.h / 2 ) ) )

translateMax ( x, y ) =
    ( x * ( scale - 1 ), y * ( scale - 1 ) )

negate ( x, y ) =
    ( -x, -y )

string ords
    = ( toString ( fst ords ) ) ++ "," ++ ( toString ( snd ords ) )

hoverAnimations =
    g [ Svg.svgNamespace
      , attribute                     "xmlns:xlink" "http://www.w3.org/1999/xlink"
      , Svg.Attributes.id             "land-hover-animation-id"
      , Svg.Attributes.xlinkHref      ""
      , Svg.Attributes.attributeType  "XML"
      ]
    [ set     [ Svg.svgNamespace
              , Svg.Attributes.class          "land-hover-class"
              , attribute                     "xmlns:xlink" "http://www.w3.org/1999/xlink"
              , Svg.Attributes.attributeType  "XML"
              , Svg.Attributes.attributeName  "stroke"
              , Svg.Attributes.to             "#822"
              , Svg.Attributes.begin          "0s"
              , Svg.Attributes.dur            duration
              , Svg.Attributes.repeatCount    "indefinite"
              ][]
    , animate [ Svg.svgNamespace
              , Svg.Attributes.class          "land-hover-class"
              , attribute                     "xmlns:xlink" "http://www.w3.org/1999/xlink"
              , Svg.Attributes.attributeType  "XML"
              , Svg.Attributes.attributeName  "stroke-width"
              , Svg.Attributes.from           "1"
              , Svg.Attributes.to             (toString ( 1.5 * scale ) )
              , Svg.Attributes.begin          "0s"
              , Svg.Attributes.dur            duration
              , Svg.Attributes.additive       "sum"
              , Svg.Attributes.repeatCount    "indefinite"
              ][]
    , animate [ Svg.svgNamespace
              , Svg.Attributes.class          "land-hover-class"
              , attribute                     "xmlns:xlink" "http://www.w3.org/1999/xlink"
              , Svg.Attributes.attributeType  "XML"
              , Svg.Attributes.attributeName  "fill"
              , Svg.Attributes.values         "#ff8; #f88; #f8f; #88f; #8ff; #8f8"
              , Svg.Attributes.begin          "0s"
              , Svg.Attributes.dur            duration
              , Svg.Attributes.repeatCount    "indefinite"
              ][]
    ]

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

filterInclude : Model -> String -> List ( String, Node )
filterInclude model id =
    List.filter (\e -> (fst e) == id ) model.lookup

filterExclude : Model -> String -> List ( String, Node )
filterExclude model id =
    List.filter (\e -> (fst e) /= id) model.lookup

bringToFront : Model -> String -> Model
bringToFront model id =
    case ( filterInclude model id ) of
      [ element ] ->
          let rest = filterExclude model id
          in
            { model | lookup <- rest ++ [ element ] }
      [] ->
          model

update : Mouse -> Model -> Model
update mouse model =
    let x = Debug.watch "mouse" mouse
        model2 = { model | mouse <- mouse, renderings <- model.renderings + 1 }
    in
      case mouse of
        Over info ->
            if | info.id == model2.mouseOver -> model2
               | otherwise -> { model2 | mouseOver <- info.id, title <- info.id }
                   {-
                   let ignore = Map.Svg.bringToFront info.id
                   in
                     { model2 | mouseOver <- info.id, title <- info.id }
                   let model3 = bringToFront model2 info.id
                   in
                     { model3 | mouseOver <- info.id, title <- info.id }
                    -}

        Out info ->
            if | List.member info.id model2.animationsOut -> { model2 | mouseOver <- "", title <- "(the big sea)" }
               | otherwise -> { model2 | animationsOut  <- model2.animationsOut  ++ [ info.id ], mouseOver <- "" }
        _ ->
            { model2 | title <- "(OOINK)" }

model : Signal Model
model =
    Signal.foldp update default mouseSignal

mouseOverChildren : List Svg.Svg
mouseOverChildren =
    [ set     [ Svg.svgNamespace
              , attribute                     "xmlns:xlink" "http://www.w3.org/1999/xlink"
              --, Svg.Attributes.xlinkHref      ref
              , Svg.Attributes.attributeType  "XML"
              , Svg.Attributes.attributeName  "stroke"
              , Svg.Attributes.to             "#822"
              , Svg.Attributes.begin          "0s"
              , Svg.Attributes.dur            duration
              , Svg.Attributes.repeatCount    "indefinite"
              ][]
    , animate [ Svg.svgNamespace
              , attribute                     "xmlns:xlink" "http://www.w3.org/1999/xlink"
              --, Svg.Attributes.xlinkHref      ref
              , Svg.Attributes.attributeType  "XML"
              , Svg.Attributes.attributeName  "stroke-width"
              , Svg.Attributes.from           "1"
              , Svg.Attributes.to             (toString ( 1.5 * scale ) )
              , Svg.Attributes.begin          "0s"
              , Svg.Attributes.dur            duration
              , Svg.Attributes.additive       "sum"
              , Svg.Attributes.repeatCount    "indefinite"
              ][]
    , animate [ Svg.svgNamespace
              , attribute                     "xmlns:xlink" "http://www.w3.org/1999/xlink"
              --, Svg.Attributes.xlinkHref      ref
              , Svg.Attributes.attributeType  "XML"
              , Svg.Attributes.attributeName  "fill"
              , Svg.Attributes.values         "#ff8; #f88; #f8f; #88f; #8ff; #8f8"
              , Svg.Attributes.begin          "0s"
              , Svg.Attributes.dur            duration
              , Svg.Attributes.repeatCount    "indefinite"
              ][]
    ]

-- VIEW
view model =

    let
        {-
        viewPath : ( String, Node ) -> Svg.Svg
        viewPath ( id, node ) =
            if | id /= model.mouseOver -> node []
               | otherwise ->
                   let ref = "#" ++ model.mouseOver
                       midpoint = negate ( centre model )
                   in
                     node mouseOverChildren
         -}
        nodes = svgNodes

        sideEffectHover = hoverEnable "land-class" "land-hover-class"

        y = Debug.watch "model.animationsOut" model.animationsOut

        x = Debug.watch "model.mouseOver" model.mouseOver

    in
      flow down [ -- show model,
                 toElement 1000 1000 (
                                       div [ class "map-container"
                                           , Html.Attributes.style [ ( "display", "block" )
                                                                   , ( "visiblity", "visible" )
                                                                   , ( "font-size", "24px" ) ]
                                           ]
                                       [ p [] [ text ( model.title )
                                              , text ( toString model.renderings )
                                              ]
                                       , div [] [ svg [ Svg.svgNamespace
                                                      , Svg.Attributes.id mapId
                                                      , name "oink"
                                                      , attribute "width" "1000px"
                                                      , attribute "height" "1000px"
                                                      , class "world-map"
                                                      , attribute "xmlns:xlink" "http://www.w3.org/1999/xlink"
                                                      ]
                                                  [ defs [ Svg.svgNamespace
                                                         , attribute "xmlns:xlink" "http://www.w3.org/1999/xlink"
                                                         ]
                                                    [ hoverAnimations
                                                    ]

                                                  , g [ Svg.svgNamespace
                                                      , attribute "xmlns:xlink" "http://www.w3.org/1999/xlink"
                                                      ] ( List.map ( \ ( id, path ) -> path ) model.lookup )
                                                  ]
                                                ]
                                       ]
                                     )
                ]

main : Signal Element
main =
    Signal.map view model
