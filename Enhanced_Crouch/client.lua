Crouched = false
CrouchedForce = false
Aimed = false
LastCam = 0
Cooldown = false

CoolDownTime = 500 -- in ms

NormalWalk = function() 
	local Player = PlayerPedId()
	SetPedMaxMoveBlendRatio(Player, 1.0)
	ResetPedMovementClipset(Player, 0.55)
	ResetPedStrafeClipset(Player)
	SetPedCanPlayAmbientAnims(Player, true)
	SetPedCanPlayAmbientBaseAnims(Player, true)
	ResetPedWeaponMovementClipset(Player)
	Crouched = false
end

SetupCrouch = function()
	while not HasAnimSetLoaded('move_ped_crouched') do
		Citizen.Wait(5)
		RequestAnimSet('move_ped_crouched')
	end
end

CanCrouch = function()
	local PlayerPed = PlayerPedId()
	if IsPedOnFoot(PlayerPed) and not IsPedJumping(PlayerPed) and not IsPedFalling(PlayerPed) and not IsPedDeadOrDying(PlayerPed) then
		return true
	else
		return false
	end
end

CrouchPlayer = function()
	local Player = PlayerPedId()
	SetPedUsingActionMode(Player, false, -1, "DEFAULT_ACTION")
	SetPedMovementClipset(Player, 'move_ped_crouched', 0.55)
	SetPedStrafeClipset(Player, 'move_ped_crouched_strafing') -- it force be on third person if not player will freeze but this func make player can shoot with good anim on crouch if someone know how to fix this make request :D
	SetWeaponAnimationOverride(Player, "Ballistic")
	Crouched = true
	Aimed = false
end

SetPlayerAimSpeed = function()
	local Player = PlayerPedId()
	SetPedMaxMoveBlendRatio(Player, 0.2)
	Aimed = true
end

IsPlayerFreeAimed = function()
	local Player = PlayerPedId()
	local PlayerID = GetPlayerIndex()
	if IsPlayerFreeAiming(PlayerID) or IsAimCamActive() or IsAimCamThirdPersonActive() then
		return true
	else
		return false
	end
end

Citizen.CreateThread( function()
	SetupCrouch()
    while true do 
		if CrouchedForce then
			local CanDo = CanCrouch()
			if CanDo and Crouched and IsPlayerFreeAimed() then
				SetPlayerAimSpeed()
			elseif CanDo and (not Crouched or Aimed) then
				CrouchPlayer()
			elseif not CanDo and Crouched then
				CrouchedForce = false
				NormalWalk()
			end
			local NowCam = GetFollowPedCamViewMode()
			if CanDo and Crouched and NowCam == 4 then
				SetFollowPedCamViewMode(LastCam)
			elseif CanDo and Crouched and NowCam ~= 4 then
				LastCam = NowCam
			end
		elseif Crouched then
			NormalWalk()
		end
		
        Citizen.Wait(5)
    end
end)

RegisterCommand('crouch', function()
	DisableControlAction(0, 36, true) -- magic
	if not Cooldown then
		CrouchedForce = not CrouchedForce
		Cooldown = true
		SetTimeout(CoolDownTime, function()
			Cooldown = false
		end)
	end
end, false)

RegisterKeyMapping('crouch', 'Crouch', 'keyboard', 'LCONTROL') -- now its better player can change to any bottom they want


-- Exports --
IsCrouched = function()
    return Crouched
end

exports("IsCrouched", IsCrouched)
