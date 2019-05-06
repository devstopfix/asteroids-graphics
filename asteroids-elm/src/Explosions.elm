module Explosions exposing (Explosion, newExplosion, renderExplosion, updateExplosions)

import Canvas exposing (..)
import Color exposing (Color)
import Point2d exposing (Point2d, coordinates)


type alias Radius =
    Float


type alias Explosion =
    { position : Point2d, color : Color, ttl : Float, radius : Radius }


explosionDurationMS =
    200


newExplosion : Point2d -> Explosion
newExplosion p =
    { position = p
    , ttl = explosionDurationMS
    , color = Color.rgba 1 1 1 0.9
    , radius = 40.0
    }


updateExplosions : Float -> List Explosion -> List Explosion
updateExplosions msSincePreviousFrame =
    List.filter isActive << List.map (updateExplosion msSincePreviousFrame)


updateExplosion : Float -> Explosion -> Explosion
updateExplosion msSincePreviousFrame explosion =
    { explosion
        | radius = explosion.radius * 1.08
        , ttl = explosion.ttl - msSincePreviousFrame
    }


isActive explosion =
    explosion.ttl > 0


renderExplosion : Transform -> Explosion -> Renderable
renderExplosion tf explosion =
    let
        ( x, y ) =
            coordinates explosion.position

        color =
            explosion.color
    in
    shapes
        [ stroke color, fill color, transform [ tf, translate x y ] ]
        [ circle ( 0, 0 ) explosion.radius ]
