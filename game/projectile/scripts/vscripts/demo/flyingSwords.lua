--10 November 2015
--Spell Description:
--     - Sends a barrage of flying swords away in the air from the caster. 
--     - When the swords hit the ground, they deal damage to all nearby targets.
--     - After a short delay, the swords will gain acceleration and charge towards the caster, dealing damage to all nearby targets.
--
--Spell Systems Used
--     - Gravity (swords falling)
--     - Velocity (inital sword velocity)
--     - Angular Velocity (swords tumbling as they go away from the caster)
--     - Acceleration (swords going towards the caster after they land)
--     - Position Tracking (dealing damage to units along the sword's path)
--     - Followers (adding additional fx's when the sword is sliding)
--     - Scaling (scaling the followers as time goes on)

--Defining some constants

--The particle name of the sword to use
local SWORD_FX = ""

--The particle name of the trail effect to put on the particle (not scaled at all)
local SWORD_FOLLOWER_TRAIL = ""

--The particle name of the red magma glow on the sword (scaled linearly)
local SWORD_FOLLOWER_GLOW = ""

--The particle name of the debris splattering from the sword (scaled linearly)
local SWORD_FOLLOWER_DEBRIS = ""

--The particle to show when the sword collides with a unit (realism factor) (shows on the target)
local BLOOD_FX = ""

--The sound to play when the sword hits the ground
local TOUCHDOWN_SFX = ""

--The sound to play while the sword is grinding along the earth
local GRIND_SFX = ""

--The sound to play when the sword disappears
local DISAPPEAR_SFX = ""

--The sound to play when the 
local CLASH_SFX = 

--The gap of theta between launches of the sword, to cover area nicely
local SWORD_LAUNCH_GAP = 90

--The variation in degrees of the launch angle (theta, too lazy to add phi variation)
local SWORD_LAUNCH_VARITAION = 45

--The speed of the sword when it is launched initially from the hero
local SWORD_LAUNCH_SPEED = 90

--The arc of the launch, also known as phi in spherical coordinates
local SWORD_LAUNCH_ARC = 45

--How much damage to deal
local DAMAGE = 50

--This will be the entry point from the data driven ability
function CastFlyingSword(keys)
	--Get the caster- important for positioning information and whatnot
	local caster = keys.caster

	--Determine the number of swords to throw. This could be variable but for the sake of the demo it is constant
	local numSwords = 30

	--Tracker variables for the inner text
	local swordCount = 0
	local lastLaunchAngle = 0

	--After 0.33 seconds, 
	Timers:CreateTimer(0.33,function()

		--Determine the launch angle for the sword - plus or minus 45 degrees of 1/4 of a rotation from the last sword. Structured randomness creates beauty.
		local launchAngle = (lastLaunchAngle + SWORD_LAUNCH_GAP) + (SWORD_LAUNCH_VARITAION / 2) * RandomFloat(-1,1)

		--Create the sword "particle": this will return a particle but the particle index can't be accessed in LUA because its a client side particle
		local sword = Spell:Particle(SWORD_FX, {yawCp = 1, positionCp = 2, scale=1})
		
		--Initializes a bounding box for the particle. This is important for collision purposes when the sword is falling into the ground.
		--If the sword were to be upside down on collision, than it would appear to go through the ground because the absolute origin is actually above the point of contact (tip of the sword)
		--The arguments are as follows: width, depth, height (x,y,z), optionalDontCenter, optionalXStart, optionalYStart, optionalZStart
		--Since the particle is symmetric, we don't need any of the optional parameters
		Spell:SetBoundingBox(50,100,50)

		--This is the collision size for unit hitting.
		--You want it to be slightly bigger since you have to guess the width of the unit, which the system guesses to be 0.
		--Therefore, the collision size is bigger to compensate.
		Spell:SetCollisionBox(100,200,100)

		--Sets the angular velocity to produce the randomized "tumbling" action. It uses the "Yaw" euler angle because it is tumbling forward
		Spell:SetAngularVelocity(Spell.YAW, sword, RandomFloat(150, 250))

		--Sets the sword to use the predefined gravity constant
		Spell:SetGravity(sword)

		--Launches the sword at the given speed in the given direction (45 degrees above the angle at which it was launched at). The trigonometry below is just standard spherical coordinates.
		Spell:SetVelocity(sword, SWORD_LAUNCH_SPEED, Vector(1 * math.sin(SWORD_LAUNCH_ARC) * math.cos(launchAngle), math.sin(SWORD_LAUNCH_ARC) * math.sin(launchAngle), math.cos(SWORD_LAUNCH_ARC)):Normalized())

		--Prepare data for the next sword launching
		lastLaunchAngle = launchAngle + SWORD_LAUNCH_GAP
		swordCount = swordCount + 1

		--When the swords hit the bottom, begin the second phase of the spell.
		Spell:OnGroundHit(sword, function(particleIndex, position)

			--Play a sound effect for cool effects.
			--The Spell convenience method isn't really needed here but im using it anyway
			Spell:EmitSound(position, TOUCHDOWN_SFX)


			--Wait a small delay before sending the acceleration
			Timers:CreateTimer(1, function()

				--Give the particle an acceleration towards the caster's original location.
				--If we wanted it to try and follow the caster, we'd use SetRadialAcceleration here. SetRadialAcceleration and SetAcceleration are equivalent of the origin doesn't change, but SetRadialAcceleration wants an entity
				--Note the third argument. It is the normalized angle of acceleration of the particle.
				--By subtracting the current position from the caster's origin, we obtain a vector that points towards the caster from the particle
				--Normalize this vector so it maintains the right speed.
				Spell:SetAcceleration(sword, SWORD_ACCELERATION, (caster:GetAbsOrigin() - position):Normalized())

				--Sets the timeout for the sword. We can specify this in two ways
				--     Distance: Have the missile expire after X units travelled
				--     Time: Have the missile expire after X seconds
				--     Function: Have a function thats called every 0.03 seconds to see if the missile to expire
				--     Note that the OnUnitHit tree of functions can also return true to terminate the missile
				--For symmetry sake, lets expire when it has travelled twice the initial distance from the caster
				--so if it was a circle, the swords would travel from one end of the circle to the other
				Spell:SetExpireDistance(sword, math.sqrt(math.pow(caster:GetAbsOrigin().y - position.x, 2) + math.pow(caster:GetAbsOrigin().y - position.y, 2)) * 2)

				--Gives the sword some follower effects
				--We can do stuff to follower if we want to (everything would be relative to the particle) but theres no point.
				--The abs origin of the follower will be constantly updated to the sword
				local follower = Spell:Follower(sword, SWORD_FOLLOWER_TRAIL)

				--For these followers, we will scale them over time (since the sword is accelerating)
				local followerGlow = Spell:Follower(sword, SWORD_FOLLOWER_GLOW)
				local followerDebris = Spell:Follower(sword, SWORD_FOLLOWER_DEBRIS)


				--This is a little bit different because the grind gets louder and louder over time.
				--It is also supposed to follow the sword.
				local grindSound = Spell:FollowerSound(sword, GRIND_SFX)

				--Set the initial volume to nothing, since you can't hear it when it isn't moving.
				Spell:SetVolume(grindSound, 0)

				--Increase the sound over time, using the same syntax as before
				Spell:SetVolumeVelocity(grindSound, 1)

				--When an enemy unit is hit by a sword, deal some damage, sound, et. al.
				--Note that the caster has to be passed in so the system knows whos an enemy.
				--Also note that this system does NOT use bounding box- it uses collision size.
				Spell:OnEnemyUnitHit(sword, caster, function(target, particleIndex, position)

					--Play a "clash!" sound
					--The spell sound methods aren't really needed here since its Wnot a dynamic sound.
					--Again, Spell:EmitSound is just a convenience method that I use to demo the system.
					Spell:EmitSound(position, CLASH_SFX)

					--Show blood on the unit
					--It uses ServerParticle because the particle isn't moving, thus no need to have it lagless.
					--Server particles also have less overhead so its good to use them when possible
					Spell:ServerParticle(target, BLOOD_FX)

					--Deal some damage to the unit hit
					--This is just a convenience method. Since its part of the spell library it deals spell damage.
					Spell:DealDamage(target, caster, DAMAGE)

				end)

				--When the sword expires, play a sound and emit a cool effect
				Spell:OnExpire(sword, function(particleIndex, position)

					--Play the sound
					Spell:EmitSound(position, EXPIRE_SFX)

					--Emit the cool effect
					Spell:ServerParticle(position, EXPIRE_FX)

					--The projectile is being taken care of, so are the followers and everything else so theres no need to worry about that

				end)
			end)
		end)


		--If the max amount of swords hasn't been reached yet then run the loop again in 1/3 of a second
		if swordCount < numSwords then
			return 0.33
		end
	end)
end