Scriptname DW_DragonSpellActivationScript extends ActiveMagicEffect  

Actor Caster

Keyword Property MagicShout Auto

GlobalVariable Property DW_DragonCloakChance Auto

MagicEffect Property DragonCloakEffect Auto

ObjectReference CasterRef

Spell Property DragonCloak Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	
	Caster = akCaster
	CasterRef = (Caster as ObjectReference)

EndEvent

Event OnMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)

	If akEffect.HasKeyword(MagicShout)
		If (CasterRef as Actor).HasMagicEffect(DragonCloakEffect)
			;None
		else
			If Utility.RandomInt(0, 100) <= DW_DragonCloakChance.GetValueInt()
				DragonCloak.Cast(CasterRef, CasterRef)
			endIf
		endIf
	endIf

EndEvent