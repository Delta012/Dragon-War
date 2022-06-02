Scriptname DW_DragonShoutManagerScript extends ActiveMagicEffect

Actor Caster

Shout Property DW_DLC1DragonDrainVitalityShout Auto
Shout Property DW_DragonMarkedForDeathShout Auto
Shout Property DW_DragonUnrelentingForceShout Auto

Spell Property DW_DLC1VoiceDragonDrainVitality Auto
Spell Property DW_VoiceDragonMarkedForDeath Auto
Spell Property DW_VoiceDragonUnrelentingForce Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)

	Caster = akCaster

EndEvent

Event OnSpellCast(Form akSpell)

	If akSpell == DW_DLC1VoiceDragonDrainVitality
		Caster.RemoveShout(DW_DLC1DragonDrainVitalityShout)
		Utility.Wait(90)
		Caster.AddShout(DW_DLC1DragonDrainVitalityShout)
	elseIf akSpell == DW_VoiceDragonMarkedForDeath
		Caster.RemoveShout(DW_DragonMarkedForDeathShout)
		Utility.Wait(120)
		Caster.AddShout(DW_DragonMarkedForDeathShout)
	elseIf akSpell == DW_VoiceDragonUnrelentingForce
		Caster.RemoveShout(DW_DragonUnrelentingForceShout)
		Utility.Wait(60)
		Caster.AddShout(DW_DragonUnrelentingForceShout)
	endIf

EndEvent