-- Based on https://github.com/meetric1/gmod-infinite-map/tree/main/lua/infmap/gm_infmap

InfMap.planet_chunk_table = InfMap.planet_chunk_table or {}

local function random(value, min, max)
	if value == 0 or not min or not max then return value end
	local perc = min + math.random() * (max - min)
	return value * (1 + perc / 100)
end

local function try_invalid_chunk(chunk, filter)
	if not chunk then 
		return 
	end

	local invalid = InfMap.planet_chunk_table[InfMap.ezcoord(chunk)]

	for k, v in ipairs(ents.GetAll()) do
		if InfMap.filter_entities(v) or not v:IsSolid() or v == filter then continue end
		if v.CHUNK_OFFSET == chunk then invalid = nil end
	end

	SafeRemoveEntity(invalid)
end

local function update_chunk(ent, chunk, oldchunk)
	if IsValid(ent) and not InfMap.filter_entities(ent) and ent:IsSolid() then
		try_invalid_chunk(oldchunk)

		local spacing = InfMap.planet_spacing / 2 - 1
		local _, megachunk = InfMap.localize_vector(chunk, InfMap.planet_spacing / 2)
		local planet_chunk, planet_radius, mat = InfMap.planet_info(megachunk[1], megachunk[2])

		if chunk ~= planet_chunk then 
			return 
		end

		if IsValid(InfMap.planet_chunk_table[InfMap.ezcoord(chunk)]) then 
			return
		end

		local planet = ents.Create("infmap_planet")
		if not IsValid(planet) then 
			return 
		end

		InfMap.prop_update_chunk(planet, chunk)

		planet:SetPlanetRadius(planet_radius)
		planet:SetModel("models/props_c17/FurnitureCouch002a.mdl")
		planet:SetMaterial(InfMap.planet_data[mat].InsideMaterial:GetName())
		planet:Spawn()

		if INF_SPACE.SB_enabled:GetBool() and not IsValid(planet.sb_planet) then
			local hash = util.CRC(tostring(chunk))
			local name = "Planet_#" .. hash

			local environment = INF_SPACE.SB_environmentCache[hash]
			if not environment then
				local defaultEnvironment, min, max = InfMap.planet_data[mat].Environment, INF_SPACE.SB_environmentRndMin, INF_SPACE.SB_environmentRndMax

				environment = {
					gravity			= random(defaultEnvironment.gravity, min, max),
					atmosphere		= defaultEnvironment.atmosphere,
					pressure		= random(defaultEnvironment.pressure, min, max),
					stemperature	= random(defaultEnvironment.stemperature, min, max),
					ltemperature	= random(defaultEnvironment.ltemperature, min, max),
					o2				= random(defaultEnvironment.o2, min, max),
					co2				= random(defaultEnvironment.co2, min, max),
					nitrogen		= random(defaultEnvironment.nitrogen, min, max),
					hydrogen		= random(defaultEnvironment.hydrogen, min, max),
				}

				INF_SPACE.SB_environmentCache[hash] = environment
			end

			local ent = INF_SPACE.CreatePlanet(planet_radius, environment.gravity, environment.atmosphere, environment.pressure, environment.stemperature, environment.ltemperature, environment.o2, environment.co2, environment.nitrogen, environment.hydrogen, nil, name)

			if IsValid(ent) then
				InfMap.prop_update_chunk(ent, chunk)
				planet:DeleteOnRemove(ent)
				planet.sb_planet = ent
			end
		end

		InfMap.planet_chunk_table[InfMap.ezcoord(chunk)] = planet
	end
end

hook.Add("PostCleanupMap", "infmap_planet_regen", function()
	for k, v in ipairs(ents.GetAll()) do
		if v.CHUNK_OFFSET then
			update_chunk(v, v.CHUNK_OFFSET)
		end
	end
end)

hook.Add("PropUpdateChunk", "infmap_infgen_planets", function(ent, chunk, oldchunk)
	update_chunk(ent, chunk, oldchunk)
end)

hook.Add("EntityRemoved", "infmap_infgen_planets", function(ent)
	try_invalid_chunk(ent.CHUNK_OFFSET, ent)
end)