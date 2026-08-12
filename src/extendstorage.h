#ifndef FS_EXTENDSTORAGE_H_074FB99DD3FEDB823AAD2D2CD6F10119
#define FS_EXTENDSTORAGE_H_074FB99DD3FEDB823AAD2D2CD6F10119

#include "container.h"

class ExtendStorage final : public Container
{
	public:
		explicit ExtendStorage(uint16_t type);

		//cylinder implementations
		ReturnValue queryAdd(int32_t index, const Thing& thing, uint32_t count,
			uint32_t flags, Creature* actor = nullptr) const override;
		ReturnValue queryMaxCount(int32_t index, const Thing& thing, uint32_t count,
			uint32_t& maxQueryCount, uint32_t flags) const override;
		void postAddNotification(Thing* thing, const Cylinder* oldParent, int32_t index, cylinderlink_t link = LINK_OWNER) override;
		void postRemoveNotification(Thing* thing, const Cylinder* newParent, int32_t index, cylinderlink_t link = LINK_OWNER) override;

		bool canRemove() const override {
			return false;
		}
};

#endif