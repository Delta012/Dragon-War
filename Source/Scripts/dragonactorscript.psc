Scriptname DragonActorScript extends Actor

Bool MiraakAppeared
Bool MiraakIntroductionHappened

Float Property DeathFXRange = 1024.0 Auto
Float Property FOVFalloff = 1600.0 Auto Hidden

ImageSpaceModIfier Property DragonFOVFX Auto

ImpactDataSet Property FXDragonLandingImpactSet Auto
ImpactDataSet Property FXDragonTailstompImpactSet Auto
ImpactDataSet Property FXDragonTakeoffImpactSet Auto

Location Property DLC2ApocryphaLocation Auto

Quest Property MQKillDragon Auto

Sound Property NPCDragonFlyby Auto

Spell Property DragonLanding Auto
Spell Property DragonTailstomp Auto
Spell Property DragonTakeoff Auto

WIFunctionsScript Property WI Auto

WorldSpace Property DLC2ApocryphaWorld Auto
	
Event OnLoad()

	RegisterForAnimationEvent(Self, "DragonLandEffect")
	RegisterForAnimationEvent(Self, "DragonForcefulLandEffect")
	RegisterForAnimationEvent(Self, "DragonTakeoffEffect")
	RegisterForAnimationEvent(Self, "DragonBiteEffect")
	RegisterForAnimationEvent(Self, "DragonTailAttackEffect")
	RegisterForAnimationEvent(Self, "DragonLeftWingAttackEffect")
	RegisterForAnimationEvent(Self, "DragonRightWingAttackEffect")
	RegisterForAnimationEvent(Self, "DragonPassByEffect")
	RegisterForAnimationEvent(Self, "flightCrashLandStart")
	RegisterForAnimationEvent(Self, "DragonKnockbackEvent")

	If !IsDead() && IsGhost()
		SetGhost(False)
	endIf

	GoToState("Alive")
	
EndEvent

Event OnReset()

	SetGhost(False)
	
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)

	If (akNewLoc != None )
		WI.RegisterDragonAttack(akNewLoc, Self)
	endIf
	
	If !IsDead() && IsGhost()
		SetGhost(False)
	endIf
	
EndEvent
	
State Alive

	Event OnCombatStateChanged(Actor akTarget, Int aeCombatState)		

		If !IsDead() && IsGhost()
			SetGhost(False)
		endIf
	
		If akTarget == Game.GetPlayer()
			WI.UpdateWIDragonTimer()
		endIf
		
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, String asEventName)
	
		If (asEventName == "DragonLandEffect")
			Game.ShakeCamera(Self, 1)
			Game.ShakeController(95, 95, 2)
			KnockAreaEffect(1, GetLength())
			AnimateFOV()
			DragonTakeoff.Cast(Self)
			PlayImpactEffect(FXDragonTakeoffImpactSet, "NPC Pelvis", 0, 0, -1, 512)
		elseIf (asEventName == "DragonForcefulLandEffect")
			DragonLanding.Cast(Self)
			PlayImpactEffect(FXDragonLandingImpactSet, "NPC Pelvis", 0, 0, -1, 512)
		elseIf (asEventName == "DragonTakeoffEffect")
			DragonTakeoff.Cast(Self)
			PlayImpactEffect(FXDragonTakeoffImpactSet, "NPC Tail8", 0, 0, -1, 2048)
		elseIf (asEventName == "DragonBiteEffect")
		elseIf (asEventName == "DragonTailAttackEffect")
			DragonTailstomp.Cast(Self)
			PlayImpactEffect(FXDragonTailstompImpactSet, "NPC Tail8", 0, 0, -1, 512)
		elseIf (asEventName == "DragonLeftWingAttackEffect")
			PlayImpactEffect(FXDragonTailstompImpactSet, "NPC LHand", 0, 0, -1, 512)
		elseIf (asEventName == "DragonRightWingAttackEffect")
			PlayImpactEffect(FXDragonTailstompImpactSet, "NPC RHand", 0, 0, -1, 512)
		elseIf (asEventName == "DragonPassByEffect")
			NPCDragonFlyby.Play(Self)
			Game.ShakeCamera(Self, 0.85)
			Game.ShakeController(0.65, 0.65, 0.5)
		elseIf (asEventName == "DragonKnockbackEvent")
			KnockAreaEffect(1, 1.5*GetLength())
			AnimateFOV(1.5*GetLength())
		endIf
		
	EndEvent

	Event OnDeath(Actor Killer)
	
		WI.startWIDragonKillQuest(Self)
		GoToState("DeadAndWaiting")

	EndEvent
	
EndState

State DeadAndWaiting

	Event OnBeginState()
	
		MQKillDragonScript MQKillDragons = MQKillDragon as MQKillDragonScript
		If DLC2ApocryphaLocation && DLC2ApocryphaWorld && (Game.GetPlayer().IsInLocation(DLC2ApocryphaLocation) || Game.GetPlayer().GetWorldSpace() == DLC2ApocryphaWorld)
			GoToState("DeadDisintegrated")
			MQKillDragons.DeathSequence(Self)
			Self.NoStalking()
		elseIf MQKillDragons.ShouldMiraakAppear(Self) && MiraakAppeared == False
			GoToState("DeadDisintegrated")
			MiraakAppeared = True
			MQKillDragons.DeathSequence(Self, MiraakAppears = True)
			Self.NoStalking()
		else
			While GetDistance(Game.GetPlayer()) > DeathFXRange
				Utility.Wait(1.0)
			endWhile
			GoToState("DeadDisintegrated")
			MQKillDragons.DeathSequence(Self)
			Self.NoStalking()
		endIf

	EndEvent
	
EndState

State DeadDisintegrated

	;None

EndState

Function AnimateFOV(Float fFOVFalloff = 1600.0)

	fFOVFalloff = FOVFalloff
	Float PlayerDist = Game.GetPlayer().GetDistance(Self)
	If PlayerDist < fFOVfalloff
		Float FOVPower = (1- (1/(fFOVfalloff/(PlayerDist))))
			If FOVPower > 1.0
				FOVPower = 1.0
			endIf
	DragonFOVFX.Apply(FOVPower)
	endIf
	
EndFunction

Function NoStalking()
	
	If !(Self.GetParentCell()).IsAttached()
		If Self.GetActorBase() as Form == Game.GetFormFromFile(0x000030D8, "Dawnguard.esm")
			Return
		else
			Self.DispelAllSpells()
			Self.SetCriticalStage(Self.CritStage_DisintegrateEnd)
		endIf
	endIf
	
EndFunction