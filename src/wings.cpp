#include "otpch.h"

#include "wings.h"

#include "pugicast.h"
#include "tools.h"

bool Wings::reload()
{
	wings.clear();
	return loadFromXml();
}

bool Wings::loadFromXml()
{
	pugi::xml_document doc;
	pugi::xml_parse_result result = doc.load_file("data/XML/wings.xml");
	if (!result) {
		printXMLError("Error - Wings::loadFromXml", "data/XML/wings.xml", result);
		return false;
	}

	for (auto wingNode : doc.child("wings").children()) {
		wings.emplace_back(
			pugi::cast<uint16_t>(wingNode.attribute("id").value()),
			wingNode.attribute("name").as_string(),
			static_cast<uint8_t>(pugi::cast<uint16_t>(wingNode.attribute("rarity").value()))
		);
	}
	wings.shrink_to_fit();
	return true;
}

Wing* Wings::getWingByID(uint16_t id)
{
	auto it = std::find_if(wings.begin(), wings.end(), [id](const Wing& wing) {
		return wing.id == id;
	});

	return it != wings.end() ? &*it : nullptr;
}

Wing* Wings::getWingByName(const std::string& name) {
	auto wingName = name.c_str();
	for (auto& it : wings) {
		if (strcasecmp(wingName, it.name.c_str()) == 0) {
			return &it;
		}
	}

	return nullptr;
}