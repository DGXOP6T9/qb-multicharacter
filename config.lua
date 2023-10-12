Config = {}
Config.StartingApartment = true -- Enable/disable starting apartments (make sure to set default spawn coords)
Config.Interior = vector3(-814.89, 181.95, 76.85) -- Interior to load where characters are previewed
Config.DefaultSpawn = vector3(-1342.71, -3194.56, 13.94) -- Default spawn coords if you have start apartments disabled
Config.PedCoords = vector4(-216.46, -1038.94, 30.14, 69.9) -- Create preview ped at these coordinates
Config.HiddenCoords = vector4(-1342.71, -3194.56, 13.94, 93.02) -- Hides your actual ped while you are in selection
Config.CamCoords = vector4(-1358.10, -3203.86, 16.43, 149.4) -- Camera coordinates for character preview screen
Config.Plane = 'nimbus'
Config.Emotes = {
    ["airportbag"] = {
        "anim@heists@narcotics@trash",
        "idle",
        "Airport Bag",
        AnimationOptions = {
            Prop = "prop_suitcase_01c",
            PropBone = 28422,
            PropPlacement = {
                0.1100,
                -0.2100,
                -0.4300,
                -11.8999,
                0.0,
                30.0000
            },
            EmoteLoop = true,
            EmoteMoving = true
        }
    },
}

Config.DefaultNumberOfCharacters = 5 -- min = 1 | max = 5
Config.PlayersNumberOfCharacters = { -- Define maximum amount of player characters by rockstar license (you can find this license in your server's database in the player table)
    { license = "license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", numberOfChars = 2 },
}

Config.PedCords = {
    [1] = vector4(-1359.81, -3215.89, 13.94, 334.16),
    [2] = vector4(-1359.37, -3215.94, 13.94, 340.61),
    [3] = vector4(-1359.3, -3209.51, 13.94, 337.77),
    [4] = vector4(-1368.30, -3211.13, 13.94, 327.38),
    [5] = vector4(-1363.19, -3207.31, 13.94, 328.18),
    [6] = vector4(-1362.18, -3211.29, 13.94, 334.16)
}

Config.TrainCoord = {
    Heading = 64.79,
    Start = vector3(-1352.5, -3231.39, 13.94),
    Stop = vector3(-1370.20, -3222.18, 13.94),
}