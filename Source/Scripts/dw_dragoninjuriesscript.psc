Scriptname DW_DragonInjuriesScript extends ActiveMagicEffect  

Spell Property InjuryAbility Auto
Spell Property InjuryAbilityRemove Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)

	akCaster.AddSpell(InjuryAbility)

EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)

	akCaster.RemoveSpell(InjuryAbilityRemove)

EndEvent