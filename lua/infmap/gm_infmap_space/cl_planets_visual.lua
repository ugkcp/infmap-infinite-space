-- Based on https://github.com/meetric1/gmod-infinite-map/tree/main/lua/infmap/gm_infmap

local atmosphere = Material("infmap/atmosphere")

hook.Add("PostDrawOpaqueRenderables", "infmap_planet_render", function()
	local client_offset = LocalPlayer().CHUNK_OFFSET
	if not client_offset then 
		return 
	end

	local amb = render.GetAmbientLightColor() * 2
	render.SetLocalModelLights()
	render.SetModelLighting(1, amb[1], amb[2], amb[3])
	render.SetModelLighting(3, amb[1], amb[2], amb[3])
	render.SetModelLighting(5, 0, 0, 0)
	render.SetModelLighting(0, amb[1], amb[2], amb[3])
	render.SetModelLighting(2, amb[1], amb[2], amb[3])
	render.SetModelLighting(4, 2, 2, 2)

	local prd = InfMap.planet_render_distance
	local _, megachunk = InfMap.localize_vector(client_offset, InfMap.planet_spacing * 0.5)

	for y = -prd, prd do
		for x = -prd, prd do
			local x = x + megachunk[1]
			local y = y + megachunk[2]
			local pos, radius, mat = InfMap.planet_info(x, y)

			local planetdata = InfMap.planet_data[mat]
			if not planetdata then 
				continue 
			end

			local final_offset = pos - client_offset
			local len = final_offset:LengthSqr()

			local planet_lod = 6
			if len < 4 then
				planet_lod = 64
			elseif len < 64 then
				planet_lod = 18
			end

			-- draw planet
			local texture = planetdata["OutsideMaterial"]
			render.SetMaterial(texture)
			render.DrawSphere(InfMap.unlocalize_vector(vector_origin, final_offset), radius, planet_lod, planet_lod)

			-- clouds
			local cloudinfo = planetdata["Clouds"]
			if cloudinfo then
				local clouds = cloudinfo[1]
				clouds:SetFloat("$alpha", cloudinfo[2])
				render.SetMaterial(clouds)
				render.DrawSphere(InfMap.unlocalize_vector(vector_origin, final_offset), radius * 1.025, planet_lod, planet_lod)
			end

			if len > 0 then continue end
			local atmosphereinfo = planetdata["Atmosphere"]
			if atmosphereinfo then
				atmosphere:SetVector("$color", atmosphereinfo[1])
				atmosphere:SetFloat("$alpha", atmosphereinfo[2])
				render.SetMaterial(atmosphere)
				render.DrawSphere(InfMap.unlocalize_vector(vector_origin, final_offset), -radius, planet_lod, planet_lod)
			end
		end
	end
end)