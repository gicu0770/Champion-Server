#include "otpch.h"

#include "auras.h"

#include "pugicast.h"
#include "tools.h"

bool Auras::reload()
{
	auras.clear();
	return loadFromXml();
}

bool Auras::loadFromXml()
{
	pugi::xml_document doc;
	pugi::xml_parse_result result = doc.load_file("data/XML/auras.xml");
	if (!result) {
		printXMLError("Error - Auras::loadFromXml", "data/XML/auras.xml", result);
		return false;
	}

	for (auto auraNode : doc.child("auras").children()) {
		auras.emplace_back(
			pugi::cast<uint16_t>(auraNode.attribute("id").value()),
			auraNode.attribute("name").as_string(),
			static_cast<uint8_t>(pugi::cast<uint16_t>(auraNode.attribute("rarity").value()))
		);
	}
	auras.shrink_to_fit();
	return true;
}

Aura* Auras::getAuraByID(uint16_t id)
{
	auto it = std::find_if(auras.begin(), auras.end(), [id](const Aura& aura) {
		return aura.id == id;
	});

	return it != auras.end() ? &*it : nullptr;
}

Aura* Auras::getAuraByName(const std::string& name) {
	auto auraName = name.c_str();
	for (auto& it : auras) {
		if (strcasecmp(auraName, it.name.c_str()) == 0) {
			return &it;
		}
	}

	return nullptr;
}