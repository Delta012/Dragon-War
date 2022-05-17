Scriptname DW_DragonSlowScript extends ActiveMagicEffect  

Spell Property SlowSpell Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)

	akTarget.AddSpell(SlowSpell, False)

EndEvent 

Event OnEffectFinish(Actor akTarget, Actor akCaster)

	akTarget.RemoveSpell(SlowSpell)

EndEvent