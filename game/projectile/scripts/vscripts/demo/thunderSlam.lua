local missileCollider = Spell:SphericalCollider(150)
local particle_follower_fx = "particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning_trail_base_lgt.vpcf"
local particle_fx = "particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning_trail_base_elec.vpcf"
local hitFx = "particles/units/heroes/hero_rhasta/forked_lightning_old.vpcf"
local hitSfx = "Hero_Leshrac.Lightning_Storm"

function Slam(keys)
	local caster = keys.caster
	local target = keys.target
	local origin = target:GetAbsOrigin()
	local missileCount = 15
	local missileDuration = 0.25
	local stun = 2
	local missile_velocity = 3000
	local thetaStep = 360 / missileCount
	local theta = thetaStep / 2

	local missileCol = function(unitHit)
		Spell:Damage(caster, unitHit,  5)
		Spell:Stun(unitHit, 2)
		Spell:ServerParticle(unitHit, hitFx)
		Spell:EmitSound(unitHit, hitSfx)
	end

	local missileCollider = Spell:ColliderGroup()

	for i=1,missileCount do

		local electric = Spell:Particle(particle_fx, caster, {positionCp= 1, duration=missileDuration})
		--local follower = Spell:Follower(electric, particle_follower_fx, {positionCp=1})
		local follower = Spell:Particle(particle_follower_fx, caster, {positionCp = 1, duration=missileDuration})
		Spell:SetVelocity(electric, missile_velocity, theta)
		Spell:SetVelocity(follower, missile_velocity, theta)

		theta = theta + thetaStep
	end
end