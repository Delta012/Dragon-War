Scriptname DW_DragonGroundingScript extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)

	akCaster.SetAllowFlying(False)

EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)

	akCaster.SetAllowFlying(True)

EndEvent