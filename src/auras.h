#ifndef FS_AURAS_H
#define FS_AURAS_H

struct Aura
{
	Aura(uint16_t id, std::string name, uint8_t rarity) :
		name(std::move(name)), id(id), rarity(rarity) {}

	std::string name;
	uint16_t id;
	uint8_t rarity;
};

class Auras
{
	public:
		bool reload();
		bool loadFromXml();
		Aura* getAuraByID(uint16_t id);
		Aura* getAuraByName(const std::string& name);

		const std::vector<Aura>& getAuras() const {
			return auras;
		}

	private:
		std::vector<Aura> auras;
};

#endif