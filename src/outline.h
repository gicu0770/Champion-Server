#ifndef FS_OUTLINES_H
#define FS_OUTLINES_H

struct Outline
{
	Outline(uint8_t id, std::string name, std::string color, std::string shader, uint8_t rarity) :
		name(std::move(name)), id(id), color(std::move(color)), shader(std::move(shader)), rarity(rarity) {}

	std::string name;
	uint8_t id;
	std::string color;
	std::string shader;
	uint8_t rarity;
};

class Outlines
{
	public:
		bool reload();
		bool loadFromXml();
		Outline* getOutlineByID(uint8_t id);
		Outline* getOutlineByName(const std::string& name);

		const std::vector<Outline>& getOutlines() const {
			return outlines;
		}

	private:
		std::vector<Outline> outlines;
};

#endif