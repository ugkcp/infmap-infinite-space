InfMap.chunk_size = 10000 -- (15 * 1024)

INF_SPACE = INF_SPACE or {
	MAP_StaticProps			= {},

	SB_environmentRndMin	= -25,
	SB_environmentRndMax	= 25,
	SB_environmentCache		= {}
}

InfMap.filter["infmap_terrain_collider"]			= true
InfMap.filter["infmap_planet"]						= true

InfMap.disable_pickup["infmap_terrain_collider"]	= true
InfMap.disable_pickup["infmap_planet"]				= true
InfMap.disable_pickup["infmap_static_prop"]			= true

InfMap.chunk_resolution			= 3
InfMap.planet_spacing			= 500
InfMap.planet_render_distance	= 12
InfMap.planet_uv_scale			= 48
InfMap.planet_resolution		= 24
InfMap.planet_tree_resolution	= 32

if SERVER then
	INF_SPACE.SB_enabled = CreateConVar("infspace_sb_enable", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "enable/disable spacebuild support. (requires server restart)")
	INF_SPACE.MAP_Seed = CreateConVar("infspace_map_seed", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "seed")

	cvars.AddChangeCallback("infspace_map_seed", function(convar_name, value_old, value_new)
		if value_old == value_new then return end

		INF_SPACE.SB_environmentCache = {}
		SetGlobal2String(convar_name, tostring(value_new))
	end)

	function INF_SPACE.initSpacebuild(radius, gravity, atmosphere, pressure, stemperature, ltemperature, o2, co2, n, h, flags, name)
		local ent = ents.Create("logic_case")

		if not IsValid(ent) then 
			return nil
		end

		ent:InfMap_SetPos(vector_origin)
		ent:Spawn()
		ent:Activate()

		ent:SetKeyValue("Case01", "planet2")
		ent:SetKeyValue("Case02", radius)
		ent:SetKeyValue("Case03", gravity)
		ent:SetKeyValue("Case04", atmosphere)
		ent:SetKeyValue("Case05", pressure)
		ent:SetKeyValue("Case06", stemperature)
		ent:SetKeyValue("Case07", ltemperature)
		ent:SetKeyValue("Case08", flags)
		ent:SetKeyValue("Case09", o2)
		ent:SetKeyValue("Case10", co2)
		ent:SetKeyValue("Case11", n)
		ent:SetKeyValue("Case12", h)
		ent:SetKeyValue("Case13", name)
	end

	function INF_SPACE.CreatePlanet(radius, gravity, atmosphere, pressure, temperature, temperature2, o2, co2, n, h, flags, name)
		local ent = ents.Create("base_sb_planet2")

		if not IsValid(ent) then 
			return nil
		end

		ent:AddEffects(EF_NODRAW)
		ent:SetModel("models/props_lab/huladoll.mdl")
		ent:SetAngles(angle_zero)
		ent:SetPos(vector_origin)
		ent:Spawn()

		ent:CreateEnvironment(radius, gravity, atmosphere, pressure, temperature, temperature2, o2, co2, n, h, flags, name)

		return ent
	end

	function INF_SPACE.SpawnStaticProp(pos, ang, model)
		local ent = ents.Create("infmap_static_prop")

		if not IsValid(ent) then 
			return nil 
		end

		ent:InfMap_SetPos(pos or vector_origin)
		ent:SetAngles(ang or angle_zero)
		ent:SetModel(model)
		ent:Spawn()

		constraint.Weld(ent, game.GetWorld(), 0, 0, 0)

		table.insert(INF_SPACE.MAP_StaticProps, ent)

		return ent
	end

	function INF_SPACE.resetSky()
		local skyPaint = ents.FindByClass("env_skypaint")[1]
		if IsValid(skyPaint) then
			skyPaint:SetTopColor(Vector(0, 0, 0))
			skyPaint:SetBottomColor(Vector(0, 0, 0))
			skyPaint:SetStarFade(4)
			skyPaint:SetDrawStars(true)
			skyPaint:SetDuskColor(Vector(0, 0, 0))
			skyPaint:SetSunSize(0)
			skyPaint:SetSunColor(Vector(1, 1, 1))
			skyPaint:SetStarSpeed(0)
		end

		local sun = ents.FindByClass("env_sun")[1]
		if IsValid(sun) then
			sun:SetKeyValue("size", 0)
			sun:SetKeyValue("overlaysize", 0)
		end
	end

	function INF_SPACE.resetStaticProps()
		for _, v in ipairs(INF_SPACE.MAP_StaticProps) do
			if IsValid(v) then 
				v:Remove() 
			end
		end

		INF_SPACE.MAP_StaticProps = {}

		if not StarGate then
			local spawnPlatform = INF_SPACE.SpawnStaticProp(Vector(0, 0, -62), angle_zero, "models/hunter/plates/plate32x32.mdl")

			if IsValid(spawnPlatform) then 
				spawnPlatform:SetMaterial("phoenix_storms/metalset_1-2") 
			end
		else
			INF_SPACE.SpawnStaticProp(Vector(0, 0, -62), angle_zero, "models/boba_fett/catwalk_build/landing_platform.mdl")
			INF_SPACE.SpawnStaticProp(Vector(-1101.853516, -348.842773, -11.303711), angle_zero, "models/iziraider/sga_ramp/sga_ramp.mdl")
			INF_SPACE.SpawnStaticProp(Vector(-490, 415, -9), Angle(0, 180, 0), "models/boba_fett/catwalk_build/bunker.mdl")
		end
	end

	function INF_SPACE.resetAll()
		INF_SPACE.resetSky()
		INF_SPACE.resetStaticProps()
	end

	if INF_SPACE.SB_enabled:GetBool() then
		INF_SPACE.initSpacebuild(2000, 1, 1, 1, 289, 300, 21, 0.45, 78, 0.55, 0, "Spawn")
	end

	hook.Add("InitPostEntity", "infmap_reset", INF_SPACE.resetAll)
	hook.Add("PostCleanupMap", "infmap_reset", INF_SPACE.resetAll)
end

function INF_SPACE.getSeed()
	return GetGlobal2String("infspace_map_seed", "1")
end