Scriptname DW_DragonSpellActivationScript extends ActiveMagicEffect  

Actor Caster

Keyword Property MagicShout Auto

GlobalVariable Property DW_DragonCloakChance Auto
GlobalVariable Property DW_DragonHardenedSkinChance Auto

MagicEffect Property DragonCloakEffect Auto
MagicEffect Property DragonHardenedSkinEffect Auto

ObjectReference CasterRef

Spell Property DragonCloak Auto
Spell Property DragonHardenedSkin Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	
	Caster = akCaster
	CasterRef = (Caster as ObjectReference)

EndEvent

Event OnMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)

	If akEffect.HasKeyword(MagicShout)
		If Caster.HasMagicEffect(DragonCloakEffect)
			;None
		else
			If Utility.RandomInt(0, 100) <= DW_DragonCloakChance.GetValueInt()
				DragonCloak.Cast(CasterRef, CasterRef)
			endIf
		endIf
		
		If Caster.HasMagicEffect(DragonHardenedSkinEffect)
			;None
		else
			If Utility.RandomInt(0, 100) <= DW_DragonHardenedSkinChance.GetValueInt()
				DragonHardenedSkin.Cast(CasterRef, CasterRef)
			endIf
		endIf
	endIf

EndEvent