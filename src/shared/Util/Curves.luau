local Curves = {}

function Curves.Sigmoid(x: number, maxValue: number, steepness: number, midpoint: number)
    --Credit to random guy in hd
    return maxValue / (1 + math.exp(-steepness * (x - midpoint)))
end

return Curves