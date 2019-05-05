module Game exposing (Game, mergeGame, newGame, viewGame)

import Asteroids exposing (..)
import Bullets exposing (Bullet, newBullet, renderBullet)
import Canvas exposing (..)
import Circle2d exposing (Circle2d, withRadius)
import Color exposing (Color)
import Dict exposing (Dict)
import Explosions exposing (Explosion, newExplosion, renderExplosion)
import Html exposing (Html)
import Html.Attributes exposing (style)
import List.FlatMap exposing (flatMap)
import Point2d exposing (origin)
import Ships exposing (..)
import StateParser exposing (AsteroidLocation, BulletLocation, Graphics, Id, ShipLocation)


type alias Dimension =
    ( Float, Float )


type alias WorldTransform =
    List Transform


type alias Game =
    { dimension : Dimension
    , asteroids : Dict Int Asteroid
    , bullets : Dict Int Bullet
    , explosions : List Explosion
    , ships : Dict String Ship
    , spaceColor : Color
    , transform : WorldTransform
    }


gameDimensions =
    ( 4000.0, 2250.0 )


newGame : Dimension -> Game
newGame dims =
    let
        ( canvas_x, canvas_y ) =
            dims

        ( game_x, game_y ) =
            gameDimensions
    in
    { dimension = dims
    , asteroids = Dict.empty
    , bullets = Dict.empty
    , explosions = []
    , ships = Dict.empty
    , spaceColor = Color.black
    , transform = gameTransform dims gameDimensions
    }


gameTransform : Dimension -> Dimension -> WorldTransform
gameTransform ( canvas_x, canvas_y ) ( game_x, game_y ) =
    [ translate 0 canvas_y
    , applyMatrix
        { m11 = canvas_x / game_x
        , m22= -1 * (canvas_y / game_y)
        , m12 = 0
        , m21 = 0
        , dx = 0
        , dy = 0
        }
    ]


viewGame : Game -> Html msg
viewGame game =
    let
        ( width, height ) =
            game.dimension

        asteroids =
            renderAsteroids game.transform (Dict.values game.asteroids)

        bullets =
            renderBullets game.transform (Dict.values game.bullets)

        explosions =
            renderExplosions game.transform game.explosions

        ships =
            renderShips game.transform (Dict.values game.ships)

        tags =
            renderTags game.transform (Dict.values game.ships)

        space =
            renderSpace game
    in
    Canvas.toHtml ( round width, round height )
        [ style "border" "2px solid darkred" ]
        (List.foldl List.append [] [ explosions, asteroids, ships, bullets, tags, space ])


renderSpace : Game -> List Renderable
renderSpace game =
    let
        ( width, height ) =
            game.dimension
    in
    [ shapes
        [ fill game.spaceColor ]
        [ rect ( 0, 0 ) width height ]
    ]


renderAsteroids tf =
    List.map (renderAsteroid tf)


renderBullets tf =
    List.map (renderBullet tf)


renderExplosions tf =
    List.map (renderExplosion tf)


renderTags tf =
    flatMap (renderTag tf)


renderShips tf =
    List.map (renderShip tf)


mergeGame : Game -> Graphics -> Game
mergeGame game graphics =
    { game
        | asteroids = updateAsteroids graphics.asteroids game.asteroids
        , bullets = updateBullets graphics.bullets game.bullets
        , explosions = appendExplosions graphics.explosions game.explosions
        , ships = updateShips graphics.ships game.ships
    }


appendExplosions new_explosions explosions =
    List.append
        explosions
        (List.map newExplosion new_explosions)


updateAsteroids asteroids game_asteroids =
    mergeAsteroids (toAsteroidMap asteroids) game_asteroids


toAsteroidMap : List AsteroidLocation -> Dict Id AsteroidLocation
toAsteroidMap =
    Dict.fromList << List.map (\a -> ( a.id, a ))


mergeAsteroids : Dict Int AsteroidLocation -> Dict Int Asteroid -> Dict Int Asteroid
mergeAsteroids graphics_asteroids game_asteroids =
    Dict.merge
        (\id a -> Dict.insert id (newAsteroid id a.location))
        (\id a b -> Dict.insert id { b | position = a.location })
        (\id _ -> identity)
        -- Remove
        graphics_asteroids
        game_asteroids
        Dict.empty


updateBullets bullets game_bullets =
    mergeBullets (toBulletMap bullets) game_bullets


toBulletMap : List BulletLocation -> Dict Id BulletLocation
toBulletMap =
    Dict.fromList << List.map (\a -> ( a.id, a ))


mergeBullets : Dict Int BulletLocation -> Dict Int Bullet -> Dict Int Bullet
mergeBullets graphics_bullets game_bullets =
    Dict.merge
        (\id a -> Dict.insert id (newBullet id a.location))
        (\id a b -> Dict.insert id { b | position = a.location })
        (\id _ -> identity)
        graphics_bullets
        game_bullets
        Dict.empty


updateShips ships game_ships =
    mergeShips (toShipMap ships) game_ships


toShipMap : List ShipLocation -> Dict String ShipLocation
toShipMap =
    Dict.fromList << List.map (\a -> ( a.id, a ))


mergeShips : Dict String ShipLocation -> Dict String Ship -> Dict String Ship
mergeShips graphics_ships game_ships =
    Dict.merge
        (\id a -> Dict.insert id (newShip id a.location a.theta))
        (\id a b -> Dict.insert id { b | position = a.location, theta = a.theta })
        (\id _ -> identity)
        graphics_ships
        game_ships
        Dict.empty
