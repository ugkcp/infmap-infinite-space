AddCSLuaFile()

ENT.Type			= "anim"
ENT.Base			= "base_anim"
ENT.Spawnable		= false

ENT.INFMAP_STATIC_PROP = true

function ENT:Initialize()
	self:DrawShadow(false)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then 
		phys:EnableMotion(false)
	end

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:CanProperty()
	return false
end

function ENT:CanTool(ply, tr, toolname, tool, button)
	if toolname == "remover" then 
		return false 
	end

	return true
end