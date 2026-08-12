#ifndef FS_SHADERS_H
#define FS_SHADERS_H

struct Shader
{
	Shader(uint8_t id, std::string name, uint8_t rarity) :
		name(std::move(name)), id(id), rarity(rarity) {}

	std::string name;
	uint8_t id;
	uint8_t rarity;
};

class Shaders
{
	public:
		bool reload();
		bool loadFromXml();
		Shader* getShaderByID(uint8_t id);
		Shader* getShaderByName(const std::string& name);

		const std::vector<Shader>& getShaders() const {
			return shaders;
		}

	private:
		std::vector<Shader> shaders;
};

#endif