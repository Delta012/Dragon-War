Scriptname DragonActorScript extends Actor

ActorBase Property Durnehviir Auto

Bool MiraakAppeared
Bool MiraakIntroductionHappened

Float Property DeathFXRange = 1024.0 Auto
Float Property FOVFalloff Auto Hidden

ImageSpaceModIfier Property DragonFOVFX Auto

ImpactDataSet Property FXDragonLandingImpactSet Auto
ImpactDataSet Property FXDragonTailstompImpactSet Auto
ImpactDataSet Property FXDragonTakeoffImpactSet Auto

Location Property DLC2ApocryphaLocation Auto

Quest Property MQKillDragon Auto

Sound Property NPCDragonFlyby Auto

WIFunctionsScript Property WI Auto

WorldSpace Property DLC2ApocryphaWorld Auto

Event OnInit()

	FOVFalloff = 1600
		If DeathFXRange == 0
			DeathFXRange = 1000
		endIf
		
		If !IsDead() && IsGhost()
			SetGhost(False)
		endIf
		
	GotoState("Alive")

EndEvent
	
Event OnReset()

	SetGhost(False)
	
EndEvent
	
Event OnLoad()

	If !IsDead()
		If IsGhost()
			SetGhost(False)
		endIf
		GotoState("Alive")
	endIf
	
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

	Event OnAnimationEvent(ObjectReference deliverator, String eventName)
	
		If (eventName == "DragonLandEffect")
			Game.ShakeCamera(Self, 1)
			Game.ShakeController(95, 95, 2)
			KnockAreaEffect(1, GetLength())
			AnimateFOV()
			PlayImpactEffect(FXDragonTakeoffImpactSet, "NPC Pelvis", 0, 0, -1, 512)
		elseIf (eventName == "DragonForcefulLandEffect")
			PlayImpactEffect(FXDragonLandingImpactSet, "NPC Pelvis", 0, 0, -1, 512)
			KnockAreaEffect(1, 2*GetLength())
		elseIf (eventName == "DragonTakeoffEffect")
			PlayImpactEffect(FXDragonTakeoffImpactSet, "NPC Tail8", 0, 0, -1, 2048)
		elseIf (eventName == "DragonBiteEffect")
		elseIf (eventName == "DragonTailAttackEffect")
			PlayImpactEffect(FXDragonTailstompImpactSet, "NPC Tail8", 0, 0, -1, 512)
		elseIf (eventName == "DragonLeftWingAttackEffect")
			PlayImpactEffect(FXDragonTailstompImpactSet, "NPC LHand", 0, 0, -1, 512)
		elseIf (eventName == "DragonRightWingAttackEffect")
			PlayImpactEffect(FXDragonTailstompImpactSet, "NPC RHand", 0, 0, -1, 512)
		elseIf (eventName == "DragonPassByEffect")
			NPCDragonFlyby.Play(Self)
			Game.ShakeCamera(Self, 0.85)
			Game.ShakeController(0.65, 0.65, 0.5)
		elseIf (eventName == "DragonKnockbackEvent")
			KnockAreaEffect(1, 1.5*GetLength())
			AnimateFOV(1.5*GetLength())
		endIf
		
	EndEvent

	Event OnDeath(Actor Killer)
	
		WI.startWIDragonKillQuest(Self)
		GotoState("DeadAndWaiting")

	EndEvent
	
EndState

State DeadAndWaiting

	Event OnBeginState()
	
		MQKillDragonScript MQKillDragons = MQKillDragon as MQKillDragonScript
		If DLC2ApocryphaLocation && DLC2ApocryphaWorld && (Game.GetPlayer().IsInLocation(DLC2ApocryphaLocation) || Game.GetPlayer().GetWorldSpace() == DLC2ApocryphaWorld)
			GotoState("DeadDisintegrated")
			MQKillDragons.DeathSequence(Self)
			RegisterForSingleUpdateGameTime(0.5)
		elseIf MQKillDragons.ShouldMiraakAppear(Self) && MiraakAppeared == False
			GotoState("DeadDisintegrated")
			MiraakAppeared = true
			MQKillDragons.DeathSequence(Self, MiraakAppears = true)
			RegisterForSingleUpdateGameTime(0.5)
		else
			While GetDistance(Game.GetPlayer()) > DeathFXRange
				Utility.Wait(1.0)
			endWhile
			GotoState("DeadDisintegrated")
			MQKillDragons.DeathSequence(Self)
			RegisterForSingleUpdateGameTime(0.5)
		endIf

	EndEvent
	
EndState

State DeadDisintegrated
EndState

Function AnimateFOV(Float fFOVFalloff = 1600.0)

	Float PlayerDist = Game.GetPlayer().GetDistance(Self)
	If PlayerDist < fFOVfalloff
		Float FOVPower = (1- (1/(fFOVfalloff/(PlayerDist))))
			If FOVPower > 1.0
				FOVPower = 1.0
			endIf
	DragonFOVFX.Apply(FOVPower)
	endIf
	
EndFunction

Function OnUpdateGameTime()

	Cell DragonCell = Self.GetParentCell()
	If !DragonCell.IsAttached()
		NoStalking()
	else
		RegisterForSingleUpdateGameTime(0.5)
	endIf
	
EndFunction

Function NoStalking()

	If Self.Durnehviir
		Return
	else
		Self.DispelAllSpells()
		Self.SetCriticalStage(Self.CritStage_DisintegrateEnd)
	endIf
	
EndFunction 