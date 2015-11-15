var globalContext=$.GetContextPanel(); while(true){if(globalContext.id == "CustomUIRoot"){break;}else{globalContext = globalContext.GetParent();}}; globalContext=globalContext.data(); gCtx=globalContext;
var Spell = {NoMovement: 0, Position: 1, Velocity: 2, Acceleration:3, Create:999, PositionCP: 0, RotationCP: 0, Functions: {}, DefineFunction:1000}
var lastTime
var missiles = {}    

function Add(v1, v2){
	if(typeof v1 == "object"){
		if(typeof v2 == "object"){
			return [v2[0]+v1[0], v2[1]+v1[1], v2[2]+v1[2]]
		}else{
			return [v2+v1[0], v2+v1[1],v2+v1[2]]
		}
	}else{
		if(typeof v2 == "object"){
			return [v1+v2[0], v1+v2[1], v1+v2[2]]
		}else{
			return v1+v2;
		}
	}
}

function Multiply(v1,v2){
	if(typeof v1 == "object"){
		if(typeof v2 == "object"){
			return [v2[0]*v1[0], v2[1]*v1[1],v2[1]*v1[2]]
		}else{
			return [v2*v1[0], v2*v1[1],v2*v1[2]]
		}
	}else{
		if(typeof v2 == "object"){
			return [v1*v2[0],v1*v2[1], v1*v2[2]]
		}else{
			return v1*v2;
		}
	}
}

function Time(){
	return Game.Time();
}

function Evaluate(x, missileStruct, dt, t){
	if(typeof x == "string"){ 
		var y = Spell.Functions[x].func(dt,t, missileStruct.args[x]) 
		$.Msg("Y : " ,y);
		return y;
	}else{
		return x;
	}
}

var fx = "";
var processmissile = false;
function Periodic(){
	if(false){
		var actualDelta = (Time() - lastTime);
		$.Msg("Tick ", actualDelta);
		var DELTA = 0.04
		lastTime = Time() 
	}else{
		var actualDelta = (Time() - lastTime);
		var DELTA = actualDelta
		lastTime = Time() 
	}
	var xTime = Time()
	for(var x in missiles){
		y = missiles[x] 
		if(y !== null){
			if(Time() - y.startTime > y.duration){
				DELTA = (y.startTime + y.duration) - lastTime
				xTime = y.startTime + y.duration
			}
			
			if(y.movementType != Spell.NoMovement){
				if(y.movementType == Spell.Acceleration){ 
					y.velocity = Add(y.velocity, Multiply(Evaluate(y.movementFunc, y, DELTA, xTime - y.startTime), DELTA)) 
					y.position = Add(y.position, Multiply(y.velocity, DELTA))
				}else if(y.movementType == Spell.Velocity){   
				
					y.velocity = Evaluate(y.movementFunc,y, DELTA, xTime - y.startTime)
					y.position = Add(y.position, Multiply(y.velocity, DELTA)) 
				}else{
					y.position = Add(y.origin, Evaluate(y.movementFunc, y,DELTA, xTime - y.startTime))
				}
			}
			
			if(y.terminated || (Time() - y.startTime > y.duration)){
				Particles.SetParticleControl(y.particle, y.positionCP, y.position)
				Particles.DestroyParticleEffect(y.particle, false)
				missiles[x] = null
			}else{
				Particles.SetParticleControl(y.particle, y.positionCP, Add(y.position, [0,0,200]))
			}
		}
		  
	}
	if(false){
		
	}else{
		$.Schedule(0.03, Periodic);
	}
}
if(false){
$.Every(0, -1, 0.04, Periodic)
}else{
	Periodic();
}

function DefineFunction(string, func){
	eval("extern = function(dt,t,args){return " + func.js + ";}");
	Spell.Functions[string] = {func:extern, args:func.args, data:func.data};
	extern = 0;
}

function InitMissile(particle,data, origin){
	missiles[particle] = {
		position: origin,
		velocity: [0,0,0],
		acceleration: [0,0,0],
		positionCP: data.positionCP || Spell.PositionCP,
		rotationCP: data.rotationCP || Spell.RotationCP,
		movementType: Spell.NoMovement,
		startTime: Time(),
		duration: data.duration,
		origin: origin,
		args: {},
	}
	return missiles[particle]
}

function Heartbeat(keys){
	
	
}


function UpdateFlag(keys){     
	var missileIndex = keys.missile
	var flagIndex = keys.flagId
	var newData = keys.data 
	
	for(var d in newData){ 
		if(typeof newData[d] == "object"){ 
			if(newData[d].x != null && newData[d].y != null && newData[d].z != null){
				newData[d] = [newData[d].x,newData[d].y,newData[d].z]
			}
		}
	}
	if(flagIndex == Spell.DefineFunction){
		$.Msg("DefineFunction " + newData.name)
		DefineFunction(newData.name, newData.data)
	}else if(flagIndex == Spell.Create){
		var missile = 0; 
		if(newData.owner){
			missile = InitMissile(missileIndex, newData, Entities.GetAbsOrigin(newData.owner))
			missiles[missileIndex].particle = Particles.CreateParticle(newData.fx, ParticleAttachment_t.PATTACH_CUSTOMORIGIN, newData.owner)
		}else if(newData.origin){
			missile = InitMissile(missileIndex, newData, newData.origin)
			missiles[missileIndex].particle = Particles.CreateParticle(newData.fx, ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0)
			Particles.SetParticleControl(missiles[missileIndex].particle, 0, newData.origin);
		}else{
			missile = InitMissile(missileIndex, newData, [0,0,0])
			missiles[missileIndex].particle = Particles.CreateParticle(newData.fx, ParticleAttachment_t.PATTACH_CUSTOMORIGIN, [0,0,0])
		}
	}else{
		var y = missiles[missileIndex]
		if(flagIndex == Spell.Position){
			y.movementType = Spell.Position
			y.movementFunc = newData.func
			y.position = newData.initial
			if(newData.args){
				y.args[y.movementFunc] = newData.args
			}
		}
		if(flagIndex == Spell.Velocity){
			y.movementType = Spell.Velocity
			y.movementFunc = newData.func
			y.velocity = newData.initial
			if(newData.args){
				y.args[y.movementFunc] = newData.args
			}
		}
		if(flagIndex == Spell.Acceleration){
			y.movementType = Spell.Acceleration
			y.movementFunc = newData.func
			y.acceleration = newData.initial
			if(newData.args){
				y.args[y.movementFunc] = newData.args
			}
		}
	}
}

(function(){
	GameEvents.Subscribe("spell_update_flag", UpdateFlag);
}());