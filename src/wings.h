#ifndef FS_WINGS_H
#define FS_WINGS_H

struct Wing
{
	Wing(uint16_t id, std::string name, uint8_t rarity) :
		name(std::move(name)), id(id), rarity(rarity) {}

	std::string name;
	uint16_t id;
	uint8_t rarity;
};

class Wings
{
	public:
		bool reload();
		bool loadFromXml();
		Wing* getWingByID(uint16_t id);
		Wing* getWingByName(const std::string& name);

		const std::vector<Wing>& getWings() const {
			return wings;
		}

	private:
		std::vector<Wing> wings;
};

#endif