--Shoots a nova of poison around the caster.

--Spell Systems Used
--    - Velocity

local POISON_FX = "particles/dazzle_poison_touch.vpcf"
local POISON_CAST_SFX = ""
local POISON_HIT_SFX = ""
local POISON_HIT_FX = ""

local numMissile = 3
local numMissileLevel = 2
local missileVelocity = 1500

function PoisonNovaCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local count = numMissile + (numMissileLevel * (ability:GetLevel() - 1))
	local thetaStep = 360 / count
	local theta = thetaStep / 2
	local dmg = 100

	local onHitHandler = function(unit)
		Spell:DealDamage(caster,unit,dmg)
	end

	for i=0,count do

		local projectile = Spell:Particle(POISON_FX, caster:GetAbsOrigin() + Vector(0,0,50) , {positionCp=0, facingCp=2, duration=2})
		Spell:SetVelocity(projectile, missileVelocity, theta)
		Spell:SetAcceleration(projectile, -(missileVelocity), theta)
		theta = theta + thetaStep

		Spell:OnEnemyUnitHit(projectile, onHitHandler)

	end

end