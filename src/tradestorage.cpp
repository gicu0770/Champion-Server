#include "otpch.h"
#include "tradestorage.h"
#include "tools.h"

TradeStorage::TradeStorage(uint16_t type) : Container(type, 20, true, true) {}

ReturnValue TradeStorage::queryAdd(int32_t, const Thing& thing, uint32_t, uint32_t flags, Creature*) const
{
	if (!hasBitSet(FLAG_NOLIMIT, flags)) {
		return RETURNVALUE_CONTAINERNOTENOUGHROOM;
	}

	const Item* item = thing.getItem();
	if (!item) {
		return RETURNVALUE_NOTPOSSIBLE;
	}

	if (item == this) {
		return RETURNVALUE_THISISIMPOSSIBLE;
	}

	if (!item->isPickupable()) {
		return RETURNVALUE_CANNOTPICKUP;
	}

	return RETURNVALUE_NOERROR;
}

void TradeStorage::postAddNotification(Thing* thing, const Cylinder* oldParent, int32_t index, cylinderlink_t)
{
	if (parent != nullptr) {
		parent->postAddNotification(thing, oldParent, index, LINK_TOPPARENT);
	}
}

void TradeStorage::postRemoveNotification(Thing* thing, const Cylinder* newParent, int32_t index, cylinderlink_t)
{
	if (parent != nullptr) {
		parent->postRemoveNotification(thing, newParent, index, LINK_TOPPARENT);
	}
}
