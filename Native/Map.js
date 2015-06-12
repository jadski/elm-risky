Elm.Native = Elm.Native || {};
Elm.Native.Map = {};
Elm.Native.Map.make = function(localRuntime) {

    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Map = localRuntime.Native.Map || {};
    if (localRuntime.Native.Map.values)
    {
        return localRuntime.Native.Map.values;
    }

    var activate = function( id ) {
        var element = document.getElementById( id );
        if ( element ) {
            var parentNode = element.parentNode;
            parentNode.removeChild( element );
            parentNode.appendChild( element );
        }
        return 1;
    }

    return localRuntime.Native.Map.values = {
        activate : activate
    };

};
