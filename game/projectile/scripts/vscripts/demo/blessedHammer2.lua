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
print("uhh?")
local BLESSED_HAMMER_FX = "particles/rapier_particle.vpcf"

function BlessedHammerCast(keys)
	print("hello")
	local caster = keys.caster 
	local ability = keys.ability 
	local count = 1
	local thetaStep = (180.0/270.0) / (6 * count)
	local theta = thetaStep / 2

Spell:DefineFunction("BlessedHammerSpiral", {
	lua=function(delta,t,argv)
		local v = 270*(t+argv['theta_indent']) * math.pi / 180
		return Vector(150*t*math.cos(v), 150*t*math.sin(v), 0) 
	--end, js="[t*Math.cos(6*(t+args[theta_indent]) * Math.pi / 180), t*Math.sin(6*(t+args[theta_indent]) * Math.pi / 180), 0]"
	end, js="[150*t*Math.cos(270*(t+args.theta_indent) * Math.PI / 180),150*t*Math.sin(270*(t+args.theta_indent) * Math.PI / 180), 0]"
	--end, js="[500*t,500*t,100]"
	})

	local onHitHandler = function(unit)
		Spell:DealDamage(caster,unit,dmg)
	end

	for i=1,count do

		local projectile = Spell:Particle(BLESSED_HAMMER_FX, caster:GetAbsOrigin() + Vector(0,0,50) , {positionCp=0, facingCp=2, duration=4})
		Spell:SetPosition(projectile, "BlessedHammerSpiral", {theta_indent= theta})
		theta = theta + thetaStep


		Spell:OnEnemyUnitHit(projectile, onHitHandler)

	end
end