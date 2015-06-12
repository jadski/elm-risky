Elm.Native = Elm.Native || {};
Elm.Native.Map = Elm.Native.Map || {};
Elm.Native.Map.Svg = Elm.Native.Map.Svg || {};
Elm.Native.Map.Svg.Events = Elm.Native.Map.Svg.Events || {};
Elm.Native.Map.Svg.Events.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Map = localRuntime.Native.Map || {};
	localRuntime.Native.Map.Svg = localRuntime.Native.Map.Svg || {};
	localRuntime.Native.Map.Svg.Events = localRuntime.Native.Map.Svg.Events || {};
	if (localRuntime.Native.Map.Svg.Events.values)
	{
		return localRuntime.Native.Map.Svg.Events.values;
	}

	var Utils = Elm.Native.Utils.make(localRuntime);

    var boxed = function( x, y, w, h ) {
        return {
            _ : {},
            x : x,
            y : y,
            w : w,
            h : h,
        }
    }

	function crash(expected, actual) {
		throw new Error(
			'expecting ' + expected + ' but got ' + JSON.stringify(actual)
		);
	}

    var makebox = function( tuple4 ) {
        if ( tuple4.ctor == "_Tuple4" ) {
            return boxed( tuple4._0, tuple4._1, tuple4._2, tuple4._3 );
        }
        crash( "a _Tuple4", tuple4 );
    }

    var empty = {
        _   : {},
        box : boxed( 0, 0, 0, 0 ),
        id  : "",
        mouse : {
            _0 : 0,
            _1 : 0,
            ctor : "_Tuple2"
        }
    };

    function decode( value ) {
        var result = empty;
        if ( value ) {
            var element = value.currentTarget;
            if ( element ) {
                result.id = element.id;
            }
            if ( element && element.getBBox ) {
                var b = element.getBBox();
                result.box = boxed( b.x, b.y, b.width, b.height );
            }
        }
        result.mouse = Utils.getXY(value);
        return result;
    }

	return localRuntime.Native.Map.Svg.Events.values = {
        makebox : makebox,
        empty   : empty,
        decode  : decode
	};

};
