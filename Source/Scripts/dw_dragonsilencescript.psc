Scriptname DW_DragonSilenceScript extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)

	akCaster.SetVoiceRecoveryTime(10000000)

EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)

	akCaster.SetVoiceRecoveryTime(0)

EndEvent