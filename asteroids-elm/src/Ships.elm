module Ships exposing (Ship, newShip, renderShip, renderTag)

import Canvas exposing (..)
import Color exposing (Color)
import SpaceShip exposing (shipWithRadius)


type alias Id =
    String


type alias Radius =
    Float


type alias Theta =
    Float


type alias Ship =
    { id : Id, position : Point, theta : Theta, color : Color, tagColor : Color, shape : Shape, radius : Radius }


shipRadius : Radius
shipRadius =
    20.0


newShip : Id -> Point -> Theta -> Ship
newShip id position theta =
    { id = id
    , color = Color.rgb255 251 255 251
    , tagColor = Color.rgba 1 1 1 0.8
    , position = position
    , radius = shipRadius
    , shape = shipWithRadius shipRadius
    , theta = theta
    }


renderShip : Transform -> Ship -> Renderable
renderShip tf ship =
    let
        ( x, y ) =
            ship.position
    in
    shapes
        [ stroke ship.color, transform [ tf, translate x y, rotate ship.theta ], lineWidth 2.0 ]
        [ ship.shape ]


renderTag : Transform -> Ship -> List Renderable
renderTag tf ship =
    let
        ( x, y ) =
            ship.position

        tag =
            ship.id

        color =
            ship.tagColor

        tagTheta =
            offset90deg ship.theta

        tagDY =
            tagOffset ship.radius
    in
    [ text [ stroke color, fill color, transform [ tf, translate x y, rotate tagTheta, translate -x -y, translate 0 tagDY ], font { size = 36, family = tagFont }, align Center ] ( x, y ) tag ]


offset90deg =
    (+) (pi / 2)


tagOffset =
    (*) 3.0


tagFont =
    "normal lighter Source Code Pro,Source Code Pro,monospace"
