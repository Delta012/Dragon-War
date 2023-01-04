Scriptname DW_DragonControllerScript extends ActiveMagicEffect

Actor SelfRef

Bool ContinueUpdate = False
Bool Enrage = False

Int CurrentShout = 0
Int iRandom = 0
Int ShoutArrayNumStored = 0

Float ShoutCooldown = 0.0

Float[] ShoutCooldownArray

Shout[] ShoutArray

GlobalVariable Property CastDrainVitalityGlobal Auto
GlobalVariable Property CastMarkedForDeathGlobal Auto
GlobalVariable Property CastUnrelentingForceGlobal Auto
GlobalVariable Property TimeScale Auto

Keyword Property MagicShout Auto

Shout Property DrainVitality Auto
Shout Property MarkedForDeath Auto
Shout Property UnrelentingForce Auto

Spell Property DragonEnrage Auto

Weapon Property Unarmed Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)

	SelfRef = akCaster
	ShoutArray = New Shout[128]
	ShoutCooldownArray = New Float[128]
	ContinueUpdate = True
	RegisterForSingleUpdate(5)
	Debug.Notification("Update Registered 1")
	
	SelfRef.EquipItem(Unarmed, True, True)

EndEvent

Event OnUpdate()

	If SelfRef.IsInCombat() && CurrentShout == 0
		ShoutSelect()
		Debug.Notification("Shout Random Choice")
	endIf
	
	If (ContinueUpdate)
		RegisterForSingleUpdate(5)
		Debug.Notification("Update Registered 2")
	endIf

	If Enrage == False
		If SelfRef.GetAVPercentage("Health") <= 0.05
			If Utility.RandomInt(1,100) <= 50
				Enrage()
			endIf
		elseIf SelfRef.GetAVPercentage("Health") <= 0.25
			If Utility.RandomInt(1,100) <= 25
				Enrage()
			endIf
		elseIf SelfRef.GetAVPercentage("Health") <= 0.5
			If Utility.RandomInt(1,100) <= 15
				Enrage()
			endIf
		elseIf SelfRef.GetAVPercentage("Health") <= 0.75
			If Utility.RandomInt(1,100) <= 5
				Enrage()
			endIf
		endIf
	elseIf Enrage == True
		If !SelfRef.HasSpell(DragonEnrage)
			Enrage = False
		endIf
	endIf

EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)

	ContinueUpdate = False
	UnregisterForUpdate()

EndEvent

Event OnDying(Actor akKiller)

	ContinueUpdate = False
	UnregisterForUpdate()
	CurrentShout = 0
	CastDrainVitalityGlobal.SetValue(0)
	CastMarkedForDeathGlobal.SetValue(0)
	CastUnrelentingForceGlobal.SetValue(0)

EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	
	If akBaseObject as Shout
		Int ShoutIndex = ShoutArray.Find(akBaseObject as Shout)
		If (ShoutIndex != -1)
			Float RemainingCooldown = ShoutCooldownArray[ShoutIndex] - Utility.GetCurrentGameTime()
			If (RemainingCooldown > 0)
				ShoutCooldown = RemainingCooldown
			endIf
		endIf

		SelfRef.SetVoiceRecoveryTime(GameTimeDaysToRealTimeSeconds(ShoutCooldown))

	endIf

EndEvent

Event OnSpellCast(Form akSpell)
	
	;If akSpell.HasKeyword(MagicShout)
   
   akSpell as Spell
   
   If !akSpell
      Return
   EndIf
   
   If ShoutHasEffectWithKeyword(akSpell as Spell, MagicShout)
		Shout akShout = SelfRef.GetEquippedShout()
		Int ShoutIndex = ShoutArray.Find(akShout)
		If (ShoutIndex != -1)
			ShoutCooldownArray[ShoutIndex] = Utility.GetCurrentGameTime() + RealTimeSecondsToGameTimeDays(SelfRef.GetVoiceRecoveryTime())
		else
			ShoutArray[ShoutArrayNumStored] = akShout
			ShoutCooldownArray[ShoutArrayNumStored] = Utility.GetCurrentGameTime() + RealTimeSecondsToGameTimeDays(SelfRef.GetVoiceRecoveryTime())
			ShoutArrayNumStored += 1
		endIf
		
		CurrentShout = 0
		
	endIf

EndEvent

Float Function RealTimeSecondsToGameTimeDays(Float RealTime)

    Float ScaledSeconds = RealTime * TimeScale.Value
    Return ScaledSeconds / (60 * 60 * 24)

EndFunction

Float Function GameTimeDaysToRealTimeSeconds(Float GameTime)

    Float GameSeconds = GameTime * (60 * 60 * 24)
    Return (GameSeconds / TimeScale.Value)

EndFunction

Bool Function ShoutHasEffectWithKeyword(Spell akSpell, Keyword akKeyword)
   
	Int iEffectCount = akSpell.GetNumEffects()
	Int iIterator = 0
	While iIterator < iEffectCount
		MagicEffect kCurrent = akSpell.GetNthEffectMagicEffect(iIterator)
		If kCurrent && kCurrent.HasKeyword(akKeyword)
			Return True
		endIf
	endWhile

	Return False

EndFunction

Function Enrage()

	DragonEnrage.Cast(SelfRef, SelfRef)
	SelfRef.SetAnimationVariableBool("DragonWeaponSpeedMult", True)
	Enrage = True

EndFunction

Function ShoutSelect()

	iRandom = Utility.RandomInt(1,3)
	
	If (iRandom == 1)
		If SelfRef.HasSpell(DrainVitality)
			Debug.Notification("Has Drain Vitality, check if can cast")
			If SelfRef.GetAVPercentage("Health") <= 0.25
				If Utility.RandomInt(1,100) <= 10
					CastDrainVitalityGlobal.SetValue(1)
					CastMarkedForDeathGlobal.SetValue(0)
					CastUnrelentingForceGlobal.SetValue(0)
					CurrentShout = 1
					Debug.Notification("Can Cast Drain Vitality")
				endIf
			else
				;Nothing
			endIf
		else
			;Nothing
		endIf
	elseIf (iRandom == 2)
		If SelfRef.HasSpell(MarkedForDeath)
			Debug.Notification("Has Marked for Death, check if can cast")
			If Utility.RandomInt(1,100) <= 15
				CastMarkedForDeathGlobal.SetValue(1)
				CastDrainVitalityGlobal.SetValue(0)
				CastUnrelentingForceGlobal.SetValue(0)
				CurrentShout = 2
				Debug.Notification("Can Cast Marked for Death")
			else
				;Nothing
			endIf
		else
			;Nothing
		endIf
	elseIf (iRandom == 3)
		If SelfRef.HasSpell(UnrelentingForce)
			Debug.Notification("Has Unrelenting Force, check if can cast")
			If Utility.RandomInt(1,100) <= 10
				CastUnrelentingForceGlobal.SetValue(1)
				CastDrainVitalityGlobal.SetValue(0)
				CastMarkedForDeathGlobal.SetValue(0)
				CurrentShout = 3
				Debug.Notification("Can Cast Unrelenting Force")
			else
				;Nothing
			endIf
		else
			;Nothing
		endIf
	endIf
	
	;elseIf (iRandom == 3)
	;	If SelfRef.IsInInterior() == 0
	;		If Utility.RandomInt(1,100) <= 10
	;			CastStormGlobal.SetValue(1)
	;			CurrentShout = 4
	;		endIf
	;	else
	;		;Nothing
	;	endIf
	
	iRandom=0

EndFunction