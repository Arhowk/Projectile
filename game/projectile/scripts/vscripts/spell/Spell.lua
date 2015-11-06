
if not Spell then
	Spell = {}
	Spell.Handlers = {}
	Spell.Missiles = {}
	SpellInit = true
else
	SpellInit = false
end

Spell.Position = 0
Spell.Velocity = 1
Spell.Acceleration = 2
Spell.Jerk = 3
Spell.Angular = 4
Spell.Radial = 8
function Spell.Periodic()
	for _,x in pairs(Spell.Handlers) do
		if x.missileStruct.deleted then
			table.remove(Spell.Handlers, _)
		else
			if x.type < Spell.Angular then
				--position
				local func = x.func
				if x.isParticle then
					if x.type == Spell.Acceleration then
						x.accumulated = (x.accumulated or 0) + (type(func) == "function" and func() or func) * 0.03
						x.missileStruct.position = x.missileStruct.position + x.accumulated * 0.03
					elseif x.type == Spell.Velocity then
						local vel =  (type(func) == "function" and func() or func) 
						x.missileStruct.position = x.missileStruct.position + vel * 0.03
						if x.missileStruct.faceForward then
							print("Face Forward", vel)
							ParticleManager:SetParticleControl(x.missileStruct.particle, 1, vel)
						end
					else
						x.missileStruct.position = (type(func) == "function" and func() or func)
					end
				else

				end
			elseif x.type < Spell.Radial then
				--angle
				if x.isParticle then

				else

				end
			else
				--radial
				if x.isParticle then

				else

				end
			end
		end
	end

	for _,c in pairs(Spell.Missiles) do
		if Time() - c.duration > c.start then
			c.deleted = true
			c.alive = false
			table.remove(Spell.Missiles, _)
		else
			--print("Position", c.position, c.start, c.duration, c.particle)
			ParticleManager:SetParticleControl(c.particle, 0, c.position + Vector(0,0,100)) 
			ParticleManager:SetParticleControl(c.particle, 3, c.position + Vector(0,0,100)) 
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
	return 0.03
end

function Spell.CreepUnitTest()

end

function Spell:EnemyUnitTest(handle)

end

Timers:CreateTimer(0.03, Spell.Periodic)

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

function Spell:Particle(particleName, optionalOriginOrOwner, controlIndex)
	if optionalOriginOrOwner and optionalOriginOrOwner.SetModel then
		return ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, optionalOriginOrOwner)
	elseif optionalOriginOrOwner then
		local p = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(p, controlIndex or 0, optionalOriginOrOwner + Vector(0,0,100)) 
		ParticleManager:SetParticleControl(p, 0, optionalOriginOrOwner + Vector(0,0,100)) 
		return p
	else
		return ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, nil)
	end
end

function Spell:GetPosition(missile)
	if type(missile) == "int" then
		return Spell.Missiles[missile].position
		--return ParticleManager:GetPos
		--todo
	else
		return missile.position
	end
end

function Spell:SetPosition(missile, func)
	if type(missile) == "int" then
		table.insert(Spell.Handlers, {func=func, type=Spell.Position, isParticle=true, missile=missile, missileStruct=Spell.Missiles[missile]})
	else

	end
end

function Spell:SetVelocity(missile, func, optionalStruct)
	if type(missile) == "number" then
		table.insert(Spell.Handlers, {missileStruct=optionalStruct or Spell.Missiles[missile], func=func, type=Spell.Velocity, isParticle=true, missile=missile})
	else
	end
end

function Spell:SetAcceleration(missile, func)
	if type(missile) == "int" then

	else

	end
end

function Spell:SetAngularVelocity(missile, func)
	if type(missile) == "int" then

	else

	end
end

function Spell:SetGravity(missile, func)
	if not func then
		if type(missile) == "int" then

		else

		end
	end
end


function Spell:SetAngularAcceleration(missile, func)
	if type(missile) == "int" then

	else

	end
end

function Spell:SetAngularPosition(missile, func)
	if type(missile) == "int" then

	else

	end
end

--radial is constant throughout
function Spell:SetRadialAcceleration(missile, func, src)

end

--pull changes based on distance from (lesser waay from)
function Spell:AddGravitationalPull(missile, func, src)

end

function Spell:CreateGroundFX(fxString, caster, distanceFrom, thetaFrom)
	if type(missile) == "int" then

	else

	end
end

function Spell:IsAlive(missile)
	return missile.alive
end

function Spell:SetUnitHit(missile, func)

end

if SpellInit then

end