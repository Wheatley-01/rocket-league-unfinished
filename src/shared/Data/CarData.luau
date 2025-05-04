export type Data = {
    Mass: number,
    Acceleration: number,
    GroundHeight: number,
    MaxForceTime: number,
    MaxForce: number,

    AirFriction: number,
    GroundFriction: number,

    HalfSize: number,
    SteerStrength: number,

    BoostStrength: number,
    JumpStrength: number,

    WheelStiffness: number,
}

return {
    ["Octane"] = {
        Mass = 1000,
        Acceleration = 1,
        GroundHeight = 4.26,
        MaxForceTime = 2,
        MaxForce = 1000,

        AirFriction = 0.01,
        GroundFriction = 0.1,

        HalfSize = 2,
        SteerStrength = 500,

        BoostStrength = 2000,
        JumpStrength = 50000,

        WheelStiffness = 0.5 --same stiffness for all wheels for now
    }
}