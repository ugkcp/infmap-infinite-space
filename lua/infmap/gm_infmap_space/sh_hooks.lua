if SERVER then
	if StarGate then
		local BlackList = {
			["infmap_clone"] = true,
			["infmap_obj_collider"] = true,
			["infmap_planet"] = true,
			["infmap_terrain_collider"] = true,
			["infmap_terrain_render"] = true,
			["infmap_static_prop"] = true,
			["base_sb_planet2"] = true
		}

		hook.Add("StarGate.GateNuke.DamageEnt", "infmap_protection", function(ent)
			if BlackList[ent:GetClass()] then return false end
		end)

		hook.Add("StarGate.SatBlast.DamageEnt", "infmap_protection", function(ent)
			if BlackList[ent:GetClass()] then return false end
		end)

		hook.Add("StarGate.BlackHole.RemoveEnt", "infmap_protection", function(ent)
			if BlackList[ent:GetClass()] then return false end
		end)

		hook.Add("StarGate.BlackHole.PushEnt", "infmap_protection", function(ent)
			if BlackList[ent:GetClass()] then return false end
		end)

		hook.Add("StarGate.Transporter.TeleportEnt", "infmap_protection", function(ent)
			if BlackList[ent:GetClass()] then return false end
		end)

		hook.Add("StarGate.Rings.TeleportEnt", "infmap_protection", function(ent)
			if BlackList[ent:GetClass()] then return false end
		end)

		hook.Add("StarGate.AtlantisTransporter.TeleportEnt", "infmap_protection", function(ent)
			if BlackList[ent:GetClass()] then return false end
		end)

		hook.Add("StarGate.DarakaWave.Disintegrate", "infmap_protection", function(ent)
			if BlackList[ent:GetClass()] then return false end
		end)

		hook.Add("StarGate.Harvester.Ent", "infmap_protection", function(ent)
			if BlackList[ent:GetClass()] then return false end
		end)

		hook.Add("OnEntityCreated", "infmap_protection", function(ent)
			if not BlackList[ent:GetClass()] then return end

			ent.CAP_EH_NoTouchTeleport	= true
			ent.NoDissolve				= true
			ent.CAP_NotSave				= true
			ent.NotTeleportable			= true
			ent.IgnoreTouch				= true
			ent.CAP_EH_NoTouch			= true
			ent.CAP_NoBlackHole			= true
		end)
	end

	hook.Add("InitPostEntity", "infmap_physenv_setup", function()
		local vel = 270079

		physenv.SetPerformanceSettings({MaxVelocity = vel, MaxAngularVelocity = vel})
		RunConsoleCommand("sv_maxvelocity", tostring(vel))
	end)
end

if CLIENT then
	local skymat = CreateMaterial("infspace_skymat", "VertexLitGeneric", {
		["$basetexture"] = "skybox/starfield",
		["$basetexturetransform"] = "center .5 .5 scale 4 4 rotate 0 translate 0 0",
		["$detailscale"] = 1
	})

	hook.Add("PostDraw2DSkyBox", "infmap_skybox", function()
		render.OverrideDepthEnable(true, false)
		render.SetMaterial(skymat)
		render.DrawSphere(EyePos(), -128, 64, 64)
		render.OverrideDepthEnable(false, false)
	end)
end