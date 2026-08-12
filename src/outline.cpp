#include "otpch.h"

#include "outline.h"

#include "pugicast.h"
#include "tools.h"

bool Outlines::reload()
{
	outlines.clear();
	return loadFromXml();
}

bool Outlines::loadFromXml()
{
	pugi::xml_document doc;
	pugi::xml_parse_result result = doc.load_file("data/XML/outlines.xml");
	if (!result) {
		printXMLError("Error - Outlines::loadFromXml", "data/XML/outlines.xml", result);
		return false;
	}

	for (auto outlineNode : doc.child("outlines").children()) {
		outlines.emplace_back(
			static_cast<uint8_t>(pugi::cast<uint16_t>(outlineNode.attribute("id").value())),
			outlineNode.attribute("name").as_string(),
			outlineNode.attribute("color").as_string(),
			outlineNode.attribute("shader").as_string(),
			static_cast<uint8_t>(pugi::cast<uint16_t>(outlineNode.attribute("rarity").value()))
		);
	}
	outlines.shrink_to_fit();
	return true;
}

Outline* Outlines::getOutlineByID(uint8_t id)
{
	auto it = std::find_if(outlines.begin(), outlines.end(), [id](const Outline& outline) {
		return outline.id == id;
	});

	return it != outlines.end() ? &*it : nullptr;
}

Outline* Outlines::getOutlineByName(const std::string& name) {
	auto outlineName = name.c_str();
	for (auto& it : outlines) {
		if (strcasecmp(outlineName, it.name.c_str()) == 0) {
			return &it;
		}
	}

	return nullptr;
}