--Diablo 2's Blessed Hammer - On crack!
--When cast, it cast four blessed hammers at 90 degree angles to eachother that travel according to the blessed hammer path.
--After reaching a set distance from the caster, they will stop moving and orbit the caster at that radius.
--After a second at that position, a ward will spawn somewhere along this radius. The ward has a gravitational pull towards all hammers.
--Pretty dope.
--Example of:
--    Functional Velocity (hammers speed up over time)
--    Functional Posititon (hammers move away from origin over time)
--    Multiple Step Projectiles (hammers change movement profiles after reaching a radius)
--    Gravitiational Pull (from the wards)
--    More unit collision
--    Angular Acceleration (spinning the hammers in circles)

local BLESSED_HAMMER_FX = "particles/dazzle_poison_touch.vpcf"

function BlessedHammerCast(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local count = 5
	local thetaStep = 360 / (6 * count)
	local theta = thetaStep / 2

Spell:DefineFunction("BlessedHammerSpiral", {
	lua=function(delta,t,argv)
		local v = 6*(t+argv['theta_indent']) * math.pi / 180
		return Vector(t*math.cos(v), t*math.sin(v), 0) 
	--end, js="[t*Math.cos(6*(t+args[theta_indent]) * Math.pi / 180), t*Math.sin(6*(t+args[theta_indent]) * Math.pi / 180), 0]"
	--end, js="[t*Math.cos(6*(t+7) * Math.pi / 180), t*Math.sin(6*(t+7) * Math.pi / 180), 0]"
	end, js="[t,t,100]"
	})

	local onHitHandler = function(unit)
		Spell:DealDamage(caster,unit,dmg)
	end

	for i=0,count do

		local projectile = Spell:Particle(BLESSED_HAMMER_FX, caster:GetAbsOrigin() + Vector(0,0,50) , {positionCp=0, facingCp=2, duration=2})
		Spell:SetPosition(projectile, "BlessedHammerSpiral", {theta_indent= theta})

		Spell:OnEnemyUnitHit(projectile, onHitHandler)

	end
end