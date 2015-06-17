Elm.Native = Elm.Native || {};
Elm.Native.Map = Elm.Native.Map || {};
Elm.Native.Map.make = function(localRuntime) {

    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Map = localRuntime.Native.Map || {};

    if (localRuntime.Native.Map.values)
    {
        return localRuntime.Native.Map.values;
    }

    var hovering = {};

    var mapClasses = function ( classes, fn ) {

        classes = classes.split( " " );
        var length = classes.length;

        for ( var i = 0; i < length; i++ ) {

            fn( classes[ i ] );

        }
    }

    var pointAnimations = function( classname, targetid ) {

        var elements = document.getElementsByClassName( classname  );
        var length = elements.length;

        for ( var i = 0; i < length; i++ ) {

            elements[ i ].setAttributeNS( "http://www.w3.org/1999/xlink", "href", targetid );

        }
    }

    var onMouseOver = function( event ) {

        var element = event.currentTarget;
        var targetid = '#' + element.id;

        mapClasses( element.getAttribute( "class" ), function( classname ) {

            var config = hovering[ classname ];

            if ( config && config.enabled ) {

                // Bring element to front
                var parent = element.parentNode;
                parent.removeChild( element );
                parent.appendChild( element );

                // Enable animations
                mapClasses( config.animationClass, function( classname ) {

                    pointAnimations( classname, targetid );

                } );
            }
        } );

    }

    var onMouseOut = function( event ) {

        var element = event.currentTarget;

        mapClasses( element.getAttribute( "class" ), function( classname ) {

            var config = hovering[ classname ];

            if ( config && config.enabled ) {

                // Disable animations
                mapClasses( config.animationClass, function( classname ) {

                    pointAnimations( classname, "" );

                } );
            }
        } );
    }

    var hoverEnable = function( elementClass, animationClass ) {

        if ( ! ( elementClass in hovering ) ) {

            hovering[ elementClass ] = { bound : false };

        }

        hovering[ elementClass ].enabled = true;

        return function ( animationClass ) {

            if ( hovering[ elementClass ].animationClass != animationClass ) {

                hovering[ elementClass ].animationClass = animationClass;

            }

            if ( ! hovering[ elementClass ].bound ) {

                var elements = document.getElementsByClassName( elementClass );

                var length = elements.length;

                if ( length > 0 ) {

                    for ( var i = 0; i < length; i++ ) {

                        var element = elements[ i ];

                        element.addEventListener( 'mouseover', onMouseOver );
                        element.addEventListener( 'mouseout', onMouseOut );

                    }
                
                    hovering[ elementClass ].bound = true;

                }
            }
        }
    }

    var hoverDisable = function( elementClass ) {

        if ( elementClass in hovering ) {

            hovering[ elementClass ].enabled = false;
            return 1;
        }
        return 0;
    }

    return localRuntime.Native.Map.Svg.values = {

        hoverEnable   : hoverEnable,
        hoverDisable  : hoverDisable

    };

};
