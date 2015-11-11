--10 November 2015
--Spell Description:
--     - Sends a barrage of flying swords away in the air from the caster. 
--     - When the swords hit the ground, they deal damage to all nearby targets.
--     - After a short delay, the swords will gain acceleration and charge towards the caster, dealing damage to all nearby targets.
--
--Spell Systems Used
--     - Gravity (swords falling)
--     - Velocity (inital sword velocity)
--     - Radial Velocity (swords tumbling as they go away from the caster)
--     - Acceleration (swords going towards the caster after they land)
--     - Position Tracking (dealing damage to units along the sword's path)
local SWORD_FX = ""
local SWORD_FOLLOWER_TRAIL = ""
local SWORD_LAUNCH_GAP = 90
local SWORD_LAUNCH_VARITAION = 45
local SWORD_LAUNCH_SPEED = 90
local SWORD_LAUNCH_ARC = 45

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

			--Wait a small delay before sending the acceleration
			Timers:CreateTimer(1, function()

				--Give the particle a constant radial acceleration towards the caster.
				--This is effectively equivalent to a constant acceleration towardst hec aster if the caster weren't to move
				--Actually, I'll do this later. Constant acceleration it is.
				--Note the third argument. It is the normalized angle of acceleration of the particle.
				--By subtracting the current position from the caster's origin, we obtain a vector that points towards the caster from the particle
				--Normalize this vector so it maintains the right speed.
				Spell:SetAcceleration(sword, SWORD_ACCELERATION, (caster:GetAbsOrigin() - position):Normalized())

				--Gives the sword some follower effects
				--We can do stuff to follower if we want to (everything would be relative to the particle) but theres no point.
				--The abs origin of the follower will be constantly updated to the sword
				local follower = Spell:Follower(sword, SWORD_FOLLOWER_TRAIL)

				--For these followers, we will scale them over time (since the sword is accelerating)
				local followerGlow = Spell:Follower(sword, SWORD_FOLLOWER_GLOW)
				local followerDebris = Spell:Follower(sword, SWORD_FOLLOWER_DEBRIS)

				--Initial scale set to 0, since they're invisible when they start
				Spell:SetScale(followerGlow, 0)
				Spell:SetScale(followerDebris, 0)

				--Scale up the followers at a rate of 100% per 1 second.
				--Note the syntax, SetScaleVelocity. It is labelled Velocity instead of Rate so that the naming conventions stay static.
				--However, it isn't SetScalePosition because SetScale can be used outside of a generic Position/Velocity/Acceleration setup
				Spell:SetScaleVelocity(followerGlow, 1)
				Spell:SetScaleVelocity(followerDebris, 1)


				--When an enemy unit is hit by a sword, deal some damage, sound, et. al.
				--Note that the caster has to be passed in so the system knows whos an enemy.
				--Also note that this system does NOT use bounding box- it uses collision size.
				Spell:OnEnemyUnitHit(sword, caster, function(particleIndex, position)

					--Play a "clash!" sound
					--{TODO}

					--Show blood on the unit
					--{TODO}

					--Deal some damage to the unit hit
					--{TODO}
				end)
			end)
		end)


		--If the max amount of swords hasn't been reached yet then run the loop again in 1/3 of a second
		if swordCount < numSwords then
			return 0.33
		end
	end)
end