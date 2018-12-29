module Vector exposing (..)


type alias Vector =
    { x : Int
    , y : Int
    }


setX : Int -> Vector -> Vector
setX x v =
    { v | x = x }


setY : Int -> Vector -> Vector
setY y v =
    { v | y = y }


add : Vector -> Vector -> Vector
add a b =
    { x = a.x + b.x
    , y = a.y + b.y
    }


sub : Vector -> Vector -> Vector
sub a b =
    { x = a.x - b.x
    , y = a.y - b.y
    }


negate : Vector -> Vector
negate { x, y } =
    { x = -x
    , y = -y
    }


scale : (Float -> Int) -> Float -> Vector -> Vector
scale toInt l { x, y } =
    { x = l * toFloat x |> toInt
    , y = l * toFloat y |> toInt
    }


dot : Vector -> Vector -> Int
dot a b =
    a.x * b.x + a.y * b.y


lengthSquared : Vector -> Int
lengthSquared { x, y } =
    x * x + y * y


length : Vector -> Float
length =
    lengthSquared >> toFloat >> sqrt


distanceSquared : Vector -> Vector -> Int
distanceSquared a b =
    lengthSquared (sub a b)


distance : Vector -> Vector -> Float
distance a b =
    sub a b |> lengthSquared |> toFloat |> sqrt


clampToRadius : Float -> Vector -> Vector
clampToRadius radius v =
    let
        ll =
            lengthSquared v |> toFloat
    in
    if ll <= radius * radius then
        v
    else
        scale truncate (radius / sqrt ll) v
