Elm.Native = Elm.Native || {};
Elm.Native.Map = Elm.Native.Map || {};
Elm.Native.Map.Svg = Elm.Native.Map.Svg || {};
Elm.Native.Map.Svg.make = function(localRuntime) {

    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Map = localRuntime.Native.Map || {};
    localRuntime.Native.Map.Svg = localRuntime.Native.Map.Svg || {};
    if (localRuntime.Native.Map.Svg.values)
    {
        return localRuntime.Native.Map.Svg.values;
    }

    var bringToFront = function( id ) {
        var element = document.getElementById( id );
        if ( element ) {
            var parentNode = element.parentNode;
            parentNode.removeChild( element );
            parentNode.appendChild( element );
        }
        return 1;
    }

    return localRuntime.Native.Map.Svg.values = {
        bringToFront : bringToFront
    };

};
