Crouched = false
CrouchedForce = false
Aimed = false
Cooldown = false
PlayerInfo = {
	playerPed = PlayerPedId(),
	playerID = GetPlayerIndex(),
	nextCheck = GetGameTimer() + 1500
}
CoolDownTime = 500 -- in ms

NormalWalk = function()
	SetPedMaxMoveBlendRatio(PlayerInfo.playerPed, 1.0)
	ResetPedMovementClipset(PlayerInfo.playerPed, 0.55)
	ResetPedStrafeClipset(PlayerInfo.playerPed)
	SetPedCanPlayAmbientAnims(PlayerInfo.playerPed, true)
	SetPedCanPlayAmbientBaseAnims(PlayerInfo.playerPed, true)
	ResetPedWeaponMovementClipset(PlayerInfo.playerPed)
	Crouched = false
end

SetupCrouch = function()
	while not HasAnimSetLoaded('move_ped_crouched') do
		Citizen.Wait(5)
		RequestAnimSet('move_ped_crouched')
	end
end

RemoveCrouchAnim = function()
	RemoveAnimDict('move_ped_crouched')
end

CanCrouch = function()
	if IsPedOnFoot(PlayerInfo.playerPed) and not IsPedInAnyVehicle(PlayerInfo.playerPed, false) and not IsPedJumping(PlayerInfo.playerPed) and not IsPedFalling(PlayerInfo.playerPed) and not IsPedDeadOrDying(PlayerInfo.playerPed) then
		return true
	else
		return false
	end
end

CrouchPlayer = function()
	SetPedUsingActionMode(PlayerInfo.playerPed, false, -1, "DEFAULT_ACTION")
	SetPedMovementClipset(PlayerInfo.playerPed, 'move_ped_crouched', 0.55)
	SetPedStrafeClipset(PlayerInfo.playerPed, 'move_ped_crouched_strafing') -- it force be on third person if not player will freeze but this func make player can shoot with good anim on crouch if someone know how to fix this make request :D
	SetWeaponAnimationOverride(PlayerInfo.playerPed, "Ballistic")
	Crouched = true
	Aimed = false
end

SetPlayerAimSpeed = function()
	SetPedMaxMoveBlendRatio(PlayerInfo.playerPed, 0.2)
	Aimed = true
end

IsPlayerFreeAimed = function()
	if IsPlayerFreeAiming(PlayerInfo.playerID) or IsAimCamActive() or IsAimCamThirdPersonActive() then
		return true
	else
		return false
	end
end

CrouchLoop = function()
	SetupCrouch()
	while CrouchedForce do
		DisableFirstPersonCamThisFrame()

		local now = GetGameTimer()
		if now >= PlayerInfo.nextCheck then
			PlayerInfo.playerPed = PlayerPedId()
			PlayerInfo.playerID = GetPlayerIndex()
			PlayerInfo.nextCheck = now + 1500
		end

		local CanDo = CanCrouch()
		if CanDo and Crouched and IsPlayerFreeAimed() then
			SetPlayerAimSpeed()
		elseif CanDo and (not Crouched or Aimed) then
			CrouchPlayer()
		elseif not CanDo and Crouched then
			CrouchedForce = false
			NormalWalk()
		end

		Citizen.Wait(5)
	end
	NormalWalk()
	RemoveCrouchAnim()
end

RegisterCommand('crouch', function()
	DisableControlAction(0, 36, true) -- magic
	if not Cooldown then
		CrouchedForce = not CrouchedForce

		if CrouchedForce then
			CreateThread(CrouchLoop) -- Magic Part 2 lamo
		end

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