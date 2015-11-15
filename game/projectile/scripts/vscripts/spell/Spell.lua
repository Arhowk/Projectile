--Last Updated: 10 November 2015
--Spell Library: This library is built to handle custom particles and projectiles for use in spell systems.
--The main advantage this library has over other libraries such as the default CreateLinearProjectile or bmd's physics library is two things
--     - The must have feature- Missiles are calculated clientside (instead of calculated serverside) which causes the projectiles to be entirely lagless and 100% accurate without the use of SetVelocity or tracking projectiles
--     - An incredible amount of features! With a super sleek API and some great demos.
--Current Features
-- [1] Position
-- [2] Velocity
-- [3] Acceleration
-- [4] Angular Position
-- [5] Angular Velocity
-- [6] Angular Acceleration
-- [7] Gravity
-- [8] Gravitational Pull
-- [10] Radial Acceleration
-- [11] Dynamic jointing/disjointing
-- [12] True particle collision

if not Spell then
	Spell = {}
	Spell.Handlers = {}
	Spell.DefinedFunctions = {}
	Spell.Missiles = {}
	SpellInit = true
else
	SpellInit = false
end
SpellRecycle = true 

--Helper Functions

function Spell:EmitSound(soundName, source)
	EmitSoundOnLocationWithCaster(soundName, source,nil) 
end











--Missile System
Spell.DefaultPositionCP = 0
Spell.DefaultRotationCP = 1
Spell.DefaultFacingCP = 2

Spell.NoMotion = 0
Spell.Position = 1
Spell.Velocity = 2
Spell.Acceleration = 3
Spell.Jerk = 4
Spell.Angular = 5
Spell.Radial = 9
Spell.Gravity = 10
Spell.GravityPull = 11
Spell.InitialPosition = 12
Spell.InitialVelocity = 13
Spell.Create = 999
Spell.DefineFunctionId = 1000
Spell.LastTime = Time()

function Spell.Periodic()
	--if SpellRecycle then
	--	SpellRecycle = false
	--	Timers:CreateTimer(0.03, Spell["Periodic"])
	--	return 
	--end
	local DELTA = (Time() - Spell.LastTime)
	Spell.LastTime = Time()
	for _,x in pairs(Spell.Handlers) do
		if x.deleted then
			table.remove(Spell.Handlers, _)
		else
			if x.movementType < Spell.Angular then
				--position
				local func = x.func
				if x.isParticle then
					if x.movementType == Spell.Acceleration then
						x.velocity = x.velocity + Spell:_Evaluate(func, x, DELTA, Time() - y.startTime) * DELTA
						x.position = x.position + x.velocity * DELTA
					elseif x.movementType == Spell.Velocity then
						local vel =  Spell:_Evaluate(func, x, DELTA, Time() - y.startTime)
						x.velocity = vel
						x.position = x.position + vel * DELTA
						if x.data and x.data.faceForward then
							ParticleManager:SetParticleControl(x.missileStruct.particle, 1, vel)
						end
					else
						x.position = x.origin + Spell:_Evaluate(func, x, DELTA, Time() - y.startTime)
					end

				end
			end
			if false then
			elseif x.movementType < Spell.Radial then
				--angle
				if x.isParticle then

				else

				end
			elseif x.movementType == Spell.Radial then
				--radial
				if x.isParticle then

				else

				end
			elseif x.movementType == Spell.Gravity then
				--gravity
			elseif x.movementType == Spell.GravityPull then
				--gravity pull
			end
		end
	end

	for _,c in pairs(Spell.Handlers) do
		if Time() - c.duration > c.start then
			c.deleted = true
			c.alive = false
			ParticleManager:DestroyParticle(c.missile, false)
			table.remove(Spell.Missiles, _)
		else 
			--print("Position", c.position, c.start, c.duration, c.particle)
			if not c.isLocal and false then
				ParticleManager:SetParticleControl(c.missile, 0, c.position + Vector(0,0,100)) 
				ParticleManager:SetParticleControl(c.missile, 3, c.position + Vector(0,0,100)) 
				--{TODO} Remove, incoprorate followers
				if c.a then
					ParticleManager:SetParticleControl(c.a, 0, c.position + Vector(0,0,100)) 
					ParticleManager:SetParticleControl(c.a, 3, c.position + Vector(0,0,100)) 
					if c.b then
						ParticleManager:SetParticleControl(c.b, 0, c.position + Vector(0,0,100)) 
						ParticleManager:SetParticleControl(c.b, 3, c.position + Vector(0,0,100)) 
						if c.c then
							ParticleManager:SetParticleControl(c.c, 0, c.position + Vector(0,0,100)) 
							ParticleManager:SetParticleControl(c.c, 3, c.position + Vector(0,0,100)) 
						end
					end
				end
			end
		end
	end
	return 0.03
end

function Spell:OnEnemyUnitHit(missile, func)

end

function Spell.CreepUnitTest()
	return true 
end

function Spell:EnemyUnitTest(handle)
	return true
end

function Spell:_InitializeMissile(missile, owner, data)	
	Spell.Handlers[missile] = {start=Time(), args={}, duration=data.duration or 999, origin=Vector(0,0,0), position=Vector(0,0,0), velocity=Vector(0,0,0), acceleration=Vector(0,0,0), movementFunc=0, owner=owner, yawFunc=0, rollFunc=0, pitchFunc = 0, movementType=0, yawType=0, rollType=0, pitchType=0, isParticle=true, missile=missile, missileStruct=Spell.Missiles[missile]}
	if owner then
		if owner.GetAbsOrigin then
			Spell.Handlers[missile].position = owner:GetAbsOrigin()
			Spell.Handlers[missile].origin = owner:GetAbsOrigin()
		else
			Spell.Handlers[missile].position = owner
			Spell.Handlers[missile].origin = owner
		end
	end
end

local missileInc = 0

function Spell:Particle(particleName, optionalOriginOrOwner, data)
	data = data or {}
	if false then
		--old system
		if optionalOriginOrOwner and optionalOriginOrOwner.SetModel then
			--Owner-based
			local p = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, optionalOriginOrOwner)
			Spell:_InitializeMissile(p, optionalOriginOrOwner, data)
			ParticleManager:SetParticleControl(p, (data and data.positionCP) and data.positionCP or Spell.DefaultPositionCP, optionalOriginOrOwner:GetAbsOrigin() )
			return p
		elseif optionalOriginOrOwner then
			print("[ERROR] [Spell] Origin-based spawning depreceated")
			local p = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, nil)
			Spell:_InitializeMissile(p, optionalOriginOrOwner, data)
			ParticleManager:SetParticleControl(p, controlIndex or 0, optionalOriginOrOwner + Vector(0,0,100)) 
			ParticleManager:SetParticleControl(p, 0, optionalOriginOrOwner + Vector(0,0,100)) 
			return p
		else
			local p = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, nil)
			Spell:_InitializeMissile(p, optionalOriginOrOwner, data)
			return p
		end
	else
		missileInc = missileInc + 1
		data.fx = particleName
		if optionalOriginOrOwner and optionalOriginOrOwner.GetAbsOrigin then
			data.owner = optionalOriginOrOwner:GetEntityIndex()
			Spell:_UpdateFlag(missileInc, Spell.Create, data)
		elseif optionalOriginOrOwner then
			data.origin = optionalOriginOrOwner
			Spell:_UpdateFlag(missileInc, Spell.Create, data)
		else
			Spell:_UpdateFlag(missileInc, Spell.Create, data)
		end
		print("FX ", particleName)
		Spell:_InitializeMissile(missileInc, optionalOriginOrOwner, data)
		return missileInc
	end
end

function Spell:Follower(host, particleName)

end

function Spell:GetPosition(missile)
	if type(missile) == "number" then
		return Spell.Missiles[missile].position
		--return ParticleManager:GetPos
		--todo
	else
		return missile.position
	end
end

function Spell:SetPosition(missile, func, ...)
	if type(missile) == "number" then
		if Spell.Handlers[missile].movementType ~= Spell.NoMotion then
			Spell.Handlers[missile].args[func] = ...
			Spell.Handlers[missile].position = Spell:_Evaluate(func, missile)
			Spell:_UpdateFlag(missile, Spell.InitialPosition, Spell.Handlers[missile].position)
		else
			Spell.Handlers[missile].func = func
			Spell.Handlers[missile].args[func] = ...
			Spell.Handlers[missile].position = Spell:_Evaluate(func, missile)
			Spell.Handlers[missile].movementType = Spell.Position
			Spell:_UpdateFlag(missile, Spell.Position, {func=func, initial=Spell:_Evaluate(func, missile)})
		end
	elseif type(missile) == "table" then
		print("[ERROR] [Spell] Attempt to give non- ")
	end
end

function Spell:SetVelocity(missile, func, ...)
	local optionalTheta = ...
	if optionalTheta and type(func) ~= "string" then
		if type(func) == "number" then
			func = Vector(func * math.cos(optionalTheta * math.pi / 180), func * math.sin(optionalTheta * math.pi / 180), 0)
		else
			func = func:Length()
			func = Vector(func * math.cos(optionalTheta * math.pi / 180), func * math.sin(optionalTheta * math.pi / 180), 0)
		end
	end

	if type(missile) == "number" then
		if Spell.Handlers[missile].movementType == Spell.Acceleration then
			Spell.Handlers[missile].velocity = Spell:_Evaluate(func )
			Spell.Handlers[missile].args[func] = arg
			Spell:_UpdateFlag(missile, Spell.InitialVelocity, Spell.Handlers[missile].velocity)
		else
			Spell.Handlers[missile].func = func
			Spell.Handlers[missile].velocity = Spell:_Evaluate(func )
			Spell.Handlers[missile].movementType = Spell.Velocity
			Spell.Handlers[missile].args[func] = arg
			Spell:_UpdateFlag(missile, Spell.Velocity, {func=func, initial=Spell:_Evaluate(func, missile)})
		end
	end
end

function Spell:SetAcceleration(missile, func, ...)
	local optionalTheta = ...
	if optionalTheta and type(func) ~= "string" then
		if type(func) == "number" then
			func = Vector(func * math.cos(optionalTheta * math.pi / 180), func * math.sin(optionalTheta * math.pi / 180), 0)
		else
			func = func:Length()
			func = Vector(func * math.cos(optionalTheta * math.pi / 180), func * math.sin(optionalTheta * math.pi / 180), 0)
		end
	end

	if type(missile) == "number" then
		Spell.Handlers[missile].func = func
		Spell.Handlers[missile].args[func] = arg
		Spell.Handlers[missile].movementType = Spell.Acceleration
		Spell:_UpdateFlag(missile, Spell.Acceleration, {func=func, initial=Spell:_Evaluate(func, missile)})
	end
end

function Spell:SetAngularVelocity(missile, func)
	if type(missile) == "number" then

	else

	end
end

function Spell:SetGravity(missile, func)
	if not func then
		if type(missile) == "number" then

		else

		end
	end
end


function Spell:SetAngularAcceleration(missile, func)
	if type(missile) == "number" then

	else

	end
end

function Spell:SetAngularPosition(missile, func)
	if type(missile) == "number" then

	else

	end
end

--radial is constant throughout
function Spell:SetRadialAcceleration(missile, func, src)

end

--pull changes based on distance from (lesser waay from)
function Spell:AddGravitationalPull(missile, func, src)
	if type(missile) == "number" then
	else

	end
end

function Spell:CreateGroundFX(fxString, caster, distanceFrom, thetaFrom)
	if type(missile) == "number" then

	else

	end
end

function Spell:IsAlive(missile)
	return missile.alive
end

function Spell:SetUnitHit(missile, func)

end

function Spell:_UpdateFlag(missile, flagId, data)
	for k,v in pairs(data) do
		if (type(v) == "table" or type(v) == "userdata") and (v.x and v.y and v.z) then
			data[k] = {x=v.x,y=v.y,z=v.z}
		end
	end
  CustomGameEventManager:Send_ServerToAllClients("spell_update_flag", {missile=missile, flagId=flagId, data=data})

end

function Spell:DefineFunction(name, tableb)
	if not tableb.lua or not tableb.js or type(tableb.lua) ~= "function" or type(tableb.js) ~= "string" then
		print("[SPELL] [Error] Tables need to contain both a 'lua' function component and a 'js' string component")
		return
	end
		--JS Define
		print("DefineFunction" .. Spell.DefineFunctionId .. name)
	Spell.DefinedFunctions[name] = tableb.lua
	Spell:_UpdateFlag(0, Spell.DefineFunctionId, {name=name, data=tableb})
	
end 

function Spell:_Evaluate(string, struct, dt,t)
	dt = dt or 0
	t = t or 0
	if type(string) ~= "string" then
		return string
	end
	if not Spell.DefinedFunctions[string] then
		print("[ERROR] [Spell] Dynamic function calls not supported yet")
		return 0
	else
		if type(struct) == "number" then
			struct = Spell.Handlers[struct]
		end
		return Spell.DefinedFunctions[string](dt,5,struct.args[string])
	end
end

function Spell:_Projectile(particleName, optionalOriginOrOwner, extraData, a1,a2,a3)
	local projectile = {
		particle = Spell:Particle(particleName, optionalOriginOrOwner),
		alive=true,
		a = a1 and Spell:Particle(a1, optionalOriginOrOwner),
		b = a2 and Spell:Particle(a2, optionalOriginOrOwner),
		c = a3 and Spell:Particle(a3, optionalOriginOrOwner),
		duration = 5,
		start = Time(),
		position = (optionalOriginOrOwner.SetModel and optionalOriginOrOwner:GetAbsOrigin() or optionalOriginOrOwner)
	}

	if extraData.tiltForward then
		projectile.faceForward = true
		 --[[Returns:void
		Set the control point data for a control on a particle effect
		]]
		--ParticleManager:SetParticleControlForward(projectile.particle, 0, Vector(1,1,1))
	--	ParticleManager:SetParticleControlForward(projectile.particle, 3, Vector(1,5,0))
	end

	if extraData.v0 then
		Spell:SetVelocity(projectile.particle, extraData.v0, projectile)
	end

	Spell.Missiles[projectile.particle] = projectile
	return projectile
end	

function Spell:Projectile(particleName, optionalOriginOrOwner, extraData, a1,a2,a3)
	local groundLock = true
	if extraData.groundLock ~= nil then
		groundLock = extraData.groundLock
	end
	local projectile = {
	  EffectName = particleName,
	  vSpawnOrigin = (optionalOriginOrOwner.SetModel and optionalOriginOrOwner:GetAbsOrigin() or optionalOriginOrOwner),
	  fDistance = extraData.distance or 99999999999,
	  fStartRadius = extraData.startRadius or extraData.radius or 100,
	  fEndRadius = extraData.endRadius or extraData.radius or 100,
	  Source = (optionalOriginOrOwner.SetModel and optionalOriginOrOwner or nil),
	  fExpireTime = extraData.time or 5,
	  vVelocity = extraData.v0 or 0,
	  UnitBehavior = extraData.destroyOnUnit and PROJECTILES_DESTROY or PROJECTILES_NOTHING,
	  bMultipleHits = extraData.destroyOnUnit or false,
	  bIgnoreSource = true,
	  TreeBehavior = extraData.destroyOnTree and PROJECTILES_DESTROY or PROJECTILES_NOTHING,
	  bCutTrees = extraData.destroyTrees or false,
	  WallBehavior = extraData.destroyOnWall and PROJECTILES_DESTROY or PROJECTILES_NOTHING,
	  GroundBehavior = extraData.destroyOnGround and PROJECTILES_DESTROY or PROJECTILES_NOTHING,
	  fGroundOffset = extraData.groundHeight or 80,
	  nChangeMax = extraData.maxChanges or 99999999999,
	  bRecreateOnChange = extraData.recreateOnChange or false,
	  bZCheck = extraData.ZCheck or false,
	  bGroundLock = groundLock,
	  iVelocityCP = extraData.cp or 0,
	  draw = true,

	  UnitTest = optionalOriginOrOwner.SetModel and Spell:EnemyUnitTest(optionalOriginOrOwner) or Spell.CreepUnitTest
	}

	if a1 then
		Spell:Particle(a1, optionalOriginOrOwner, 3)
	end
	if a2 then
		Spell:Particle(a2, optionalOriginOrOwner, 3)
	end
	if a3 then
		Spell:Particle(a3, optionalOriginOrOwner, 3)
	end


	return Projectiles:CreateProjectile(projectile)
end

if SpellInit then
	SpellRecycle = false

Timers:CreateTimer(0.03, Spell.Periodic)
end