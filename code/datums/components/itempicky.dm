/// You can only hold whitelisted items
/datum/component/itempicky
	can_transfer = TRUE
	/// Typecache of items you can hold
	var/whitelist
	/// Message shown if you try to pick up an item not in the whitelist
	var/message = "You don't like %TARGET, why would you hold it?"
	/// An optional callback we check for overriding our whitelist
	var/datum/callback/tertiary_condition = null

/datum/component/itempicky/Initialize(whitelist, message, tertiary_condition)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	src.whitelist = whitelist
	if(message)
		src.message = message
	if(tertiary_condition)
		src.tertiary_condition = tertiary_condition

/datum/component/itempicky/Destroy(force)
	tertiary_condition = null
	return ..()

/datum/component/itempicky/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_TRY_PUT_IN_HAND, PROC_REF(particularly))

/datum/component/itempicky/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_TRY_PUT_IN_HAND)

/datum/component/itempicky/PostTransfer(datum/new_parent)
	if(!ismob(new_parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/itempicky/InheritComponent(datum/component/itempicky/friend, i_am_original, list/arguments)
	if(i_am_original)
		whitelist = friend.whitelist
		message = friend.message

/datum/component/itempicky/proc/particularly(datum/source, obj/item/pickingup)
	SIGNAL_HANDLER
	// if we were passed the output of a callback, check against that
	if(!tertiary_condition?.Invoke() && !is_type_in_typecache(pickingup, whitelist))
		to_chat(source, span_warning("[replacetext(message, "%TARGET", pickingup.declent_ru(ACCUSATIVE))]"))
		return COMPONENT_LIVING_CANT_PUT_IN_HAND
