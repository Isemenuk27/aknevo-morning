if game.GetMap() != "gm_aknevo_morning" then return end

local FogStart = 100
local FogZClip = 5450
local FogEnd = FogZClip - 150


if ( CLIENT ) then
	local s = FogEnd * 0.6
	local x = Vector( s, s, s ) 

	local coln = 0.446 * 255
	--local col = Color(133, 144, 153)

	local col = Color( coln, coln, coln )
	local sky_cam_pos = Vector(2688, -9088, 9472)
	local tempv = Vector(0, 0, 0)

	local function f2DSkyBox() 
		render.SetColorMaterial() 
		render.OverrideDepthEnable( true, false )

		--render.DrawBox( sky_cam_pos, angle_zero, x * .05, -x * .05, col ) 
		render.DrawBox( EyePos(), angle_zero, x, -x, col )

		render.OverrideDepthEnable( false, false ) 
	end

	hook.Add("PostDraw2DSkyBox", "AKNEVO.FOG", f2DSkyBox)

	local Dents = 1

	local function FogRender()
		render.FogMode( MATERIAL_FOG_LINEAR )
		render.FogStart( FogStart )
		render.FogEnd( FogEnd )
		--Dents = math.Approach( Dents, (CamHeight > -241) and 1 or 0, FrameTime() * 600 )

		render.FogMaxDensity( Dents )
		render.FogColor( col.r, col.g, col.b )

		return true
	end

	hook.Add( "SetupWorldFog", "AKNEVO.FOG", FogRender )


	function SetupSkyFog( skyboxscale )
		render.FogMode( MATERIAL_FOG_LINEAR )
		render.FogStart( FogStart * skyboxscale )
		render.FogEnd( FogEnd * skyboxscale )
		render.FogMaxDensity( Dents )

		render.FogColor( col.r, col.g, col.b )

		return true
	end

	hook.Add( "SetupSkyboxFog", "AKNEVO.FOG", SetupSkyFog )

	local function f() 
		render.SetColorMaterial() 
		render.OverrideDepthEnable( true, false )

		local ScaledEye = EyePos() / 16

		tempv.x = sky_cam_pos.z + ScaledEye.x
		tempv.y = sky_cam_pos.z + ScaledEye.y
		tempv.z = sky_cam_pos.z + ScaledEye.z

		render.DrawBox( tempv, angle_zero, x * .05, -x * .05, col ) 
		--render.DrawBox( EyePos(), angle_zero, x, -x, col )

		render.OverrideDepthEnable( false, false ) 
	end

	hook.Add("PreDrawSkyBox", "AKNEVO.FOG", f)

else
	local fog_controller = ents.FindByClass("env_fog_controller")[1]
	local sky_camera = ents.FindByClass("sky_camera")[1]

	if IsValid(fog_controller) then
		fog_controller:Fire("SetStartDist", tostring(FogStart) )
		fog_controller:Fire("SetEndDist", tostring(FogEnd) )
		fog_controller:Fire("SetFarZ", tostring(FogZClip) )
		fog_controller:Fire("SetMaxDensity", "1")
	end

	if IsValid(sky_camera) then
		sky_camera:SetSaveValue( "fogstart", tostring(FogStart) )
		sky_camera:SetSaveValue( "fogend", tostring(FogEnd) )
	end

	local KeyToVal = {
		["fogstart"] = FogStart,
		["fogend"] = FogEnd,
		["fogmaxdensity"] = 1
	}

	hook.Add( "EntityKeyValue", "AKNEVO", function( sky_camera, key, value )
		if IsValid( sky_camera ) and sky_camera:GetClass() == "sky_camera" then
			sky_camera:SetKeyValue( key, tostring( KeyToVal[key] ) )
		end
	end )

	local position = Vector( 4627.911133, 608.596375, 141.480865 )
	local angles = Angle( -7.532, -74.913, 0.648 )
	local model = "models/props_debris/concrete_chunk07a.mdl"

	local function MapCleanup()
		local ent = ents.Create( "prop_dynamic" )
		ent:SetModel( model )
		ent:SetAngles( angles )
		ent:SetPos( position )

		ent:Spawn()
		ent:SetMoveType( MOVETYPE_NONE )
	end

	hook.Add( "InitPostEntity", "AKNEVO", MapCleanup )
	hook.Add( "PostCleanupMap", "AKNEVO", MapCleanup )

end