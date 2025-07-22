-- Based on https://github.com/meetric1/gmod-infinite-map/tree/main/lua/infmap/gm_infmap

InfMap.simplex = include("simplex.lua")

local noise2d = InfMap.simplex.Noise2D

InfMap.planet_data = {
	{ -- mercury
		OutsideMaterial = Material("infmap_planets/mercury"),
		InsideMaterial = Material("infmap_planets/mercury_inside"),

		Environment = {
			gravity = 0.38,
			atmosphere = 0,
			pressure = 0,
			stemperature = 703,
			ltemperature = 93,
			o2 = 0,
			co2 = 0,
			nitrogen = 0,
			hydrogen = 0
		}
	},

	{ -- venus
		OutsideMaterial = Material("infmap_planets/venus"),
		InsideMaterial = Material("infmap_planets/venus_inside"),

		Atmosphere = {
			Vector(0.9, 0.75, 0.4),
			0.25
		},

		Clouds = {
			Material("infmap_planets/venus_clouds"),
			1
		},

		Environment = {
			gravity = 0.9,
			atmosphere = 1,
			pressure = 92,
			stemperature = 738,
			ltemperature = 735,
			o2 = 0,
			co2 = 96.5,
			nitrogen = 3.5,
			hydrogen = 0
		}
	},

	{ -- earth
		OutsideMaterial = Material("infmap_planets/earth"),
		InsideMaterial = Material("infmap/flatgrass"),

		Atmosphere = {
			Vector(0.66, 0.86, 0.95),
			0.25
		},

		Clouds = {
			Material("infmap_planets/earth_clouds"),
			1
		},

		Environment = {
			gravity = 1,
			atmosphere = 1,
			pressure = 1,
			stemperature = 288,
			ltemperature = 184,
			o2 = 21,
			co2 = 0.04,
			nitrogen = 78,
			hydrogen = 0.05
		}
	},

	{ -- mars
		OutsideMaterial = Material("infmap_planets/mars"),
		InsideMaterial = Material("infmap_planets/mars_inside"),

		Atmosphere = {
			Vector(0.9, 0.65, 0.55),
			0.5
		},

		Environment = {
			gravity = 0.38,
			atmosphere = 1,
			pressure = 0.006,
			stemperature = 218,
			ltemperature = 148,
			o2 = 0.13,
			co2 = 95,
			nitrogen = 2.7,
			hydrogen = 0
		}
	},

	{ -- jupiter
		OutsideMaterial = Material("infmap_planets/jupiter"),
		InsideMaterial = Material("infmap_planets/jupiter_inside"),

		Atmosphere = {
			Vector(0.9, 0.9, 0.8),
			0.6
		},

		Environment = {
			gravity = 2.53,
			atmosphere = 1,
			pressure = 1000,
			stemperature = 165,
			ltemperature = 128,
			o2 = 0,
			co2 = 0,
			nitrogen = 0.3,
			hydrogen = 89.8
		}
	},

	{ -- saturn
		OutsideMaterial = Material("infmap_planets/saturn"),
		InsideMaterial = Material("infmap_planets/saturn_inside"),

		Atmosphere = {
			Vector(0.9, 0.85, 0.7),
			0.6
		},

		Environment = {
			gravity = 1.07,
			atmosphere = 1,
			pressure = 140,
			stemperature = 134,
			ltemperature = 95,
			o2 = 0,
			co2 = 0,
			nitrogen = 0.1,
			hydrogen = 96.3
		}
	},

	{ -- uranus
		OutsideMaterial = Material("infmap_planets/uranus"),
		InsideMaterial = Material("infmap_planets/uranus_inside"),

		Atmosphere = {
			Vector(0.5, 0.65, 0.7),
			0.8
		},

		Environment = {
			gravity = 0.89,
			atmosphere = 1,
			pressure = 1.2,
			stemperature = 76,
			ltemperature = 49,
			o2 = 0,
			co2 = 0,
			nitrogen = 0,
			hydrogen = 82.5
		}
	},

	{ -- neptune
		OutsideMaterial = Material("infmap_planets/neptune"),
		InsideMaterial = Material("infmap_planets/neptune_inside"),

		Atmosphere = {
			Vector(0.2, 0.25, 0.5),
			0.8
		},

		Environment = {
			gravity = 1.14,
			atmosphere = 1,
			pressure = 1.5,
			stemperature = 72,
			ltemperature = 55,
			o2 = 0,
			co2 = 0,
			nitrogen = 0,
			hydrogen = 80
		}
	},

	{ -- moon
		OutsideMaterial = Material("infmap_planets/moon"),
		InsideMaterial = Material("infmap_planets/moon_inside"),

		Environment = {
			gravity = 0.17,
			atmosphere = 0,
			pressure = 0,
			stemperature = 380,
			ltemperature = 100,
			o2 = 0,
			co2 = 0,
			nitrogen = 0,
			hydrogen = 0
		}
	},
}

function InfMap.height_function(x, y) 
	return 0
end

function InfMap.planet_height_function(x, y)
	return (noise2d(x / 15000, y / 15000) * 2000) / math.max(noise2d(x / 9000, y / 9000) * 10, 1)
end

function InfMap.planet_info(x, y)
	local seed = INF_SPACE.getSeed()
	local chunkpos = tostring(x .. y)

	local spacing = InfMap.planet_spacing / 2 - 1
	local random_x = math.floor(util.SharedRandom(seed .. "_PLANET_X_" .. chunkpos, -spacing, spacing))
	local random_y = math.floor(util.SharedRandom(seed .. "_PLANET_Y_" .. chunkpos, -spacing, spacing))
	local random_z = math.floor(util.SharedRandom(seed .. "_PLANET_Z_" .. chunkpos, -spacing, spacing))

	local planet_radius = math.floor(util.SharedRandom(seed .. "_PLANET_RADIUS_" .. chunkpos, InfMap.chunk_size / 10, InfMap.chunk_size))
	local planet_type = math.Round(util.SharedRandom(seed .. "_PLANET_TYPE_" .. chunkpos, 1, #InfMap.planet_data))
	local planet_pos = Vector(x * InfMap.planet_spacing + random_x, y * InfMap.planet_spacing + random_y, random_z)

	return planet_pos, planet_radius, planet_type
end