package com.funnyhatsoftware.spacedock;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;

import android.util.Log;

public class DataLoader extends DefaultHandler {
	Universe universe;
	String xmlFilePath;
	InputStream xmlInput;
	String currentText;
	Map<String, Object> parsedData = new HashMap<String, Object>();
	Map<String, Object> currentElement = null;
	Map<String, String> currentAttributes = new HashMap<String, String>();
	ArrayList<Object> currentList = null;
	ArrayList<String> elementNameStack = new ArrayList<String>();
	ArrayList<ArrayList<Object>> listStack = new ArrayList<ArrayList<Object>>();
	ArrayList<Object> elementStack = new ArrayList<Object>();
	HashSet<String> listElementNames = new HashSet<String>();
	HashSet<String> itemElementNames = new HashSet<String>();
	String currentVersion;
	String dataVersion;
	boolean versionMatched;
	boolean versionOnly;
	boolean force;

	public DataLoader(Universe targetUniverse, InputStream xmlTargetInput) {
		universe = targetUniverse;
		xmlInput = xmlTargetInput;
		String[] a = { "Sets", "Upgrades", "Captains", "Ships", "Resources",
				"Maneuvers", "ShipClassDetails", "Flagships" };
		for (String v: a) {
			listElementNames.add(v);
		}
		String[] b = { "Set", "Upgrade", "Captain", "Ship", "Resource",
				"Maneuver", "ShipClassDetail", "Flagship" };
		for (String v: b) {
			itemElementNames.add(v);
		}
		
	}

	@SuppressWarnings("unchecked")
	public boolean load() throws ParserConfigurationException, SAXException,
			IOException {
		SAXParserFactory spf = SAXParserFactory.newInstance();
		SAXParser sp = spf.newSAXParser();

		XMLReader xr = sp.getXMLReader();

		xr.setContentHandler(this);

		xr.parse(new InputSource(xmlInput));
		ArrayList<Object> shipData = (ArrayList<Object>) parsedData.get("Ships");
		for (Object oneShipDataObject : shipData) {
			Map<String,Object> oneShipData = (Map<String, Object>) oneShipDataObject;
			String externalId = (String)oneShipData.get("Id");
			Ship ship = universe.ships.get(externalId);
			if (ship == null) {
				ship = new Ship();
				universe.ships.put(externalId, ship);
			}
			ship.update(oneShipData);
		}
		return true;
	}

	String parentName() {
		String parName = "";
		if (elementNameStack.size() > 1) {
			parName = elementNameStack.get(elementNameStack.size() - 2);
		}
		return parName;
	}

	boolean isDataItem(String elementName) {
		if (!itemElementNames.contains(elementName)) {
			return false;
		}

		if (elementName == "Set") {
			String parentName = parentName();
			if (parentName != "Sets") {
				return false;
			}
		}
		return true;
	}

	boolean isList(String elementName) {
		if (!listElementNames.contains(elementName)) {
			return false;
		}
		if (elementName == "Set") {
			String parentName = parentName();
			if (parentName != "Sets") {
				return false;
			}
		}
		return true;
	}

	@Override
	public void startElement(String uri, String localName, String qName,
			Attributes attributes) throws SAXException {
		super.startElement(uri, localName, qName, attributes);
		elementNameStack.add(localName);

		if (attributes.getLength() > 0) {
			currentAttributes.clear();
			for (int i = 0; i < attributes.getLength(); i++) {
				String aName = attributes.getLocalName(i);
				String aValue = attributes.getValue(i);
				currentAttributes.put(aName, aValue);
			}
		} else {
			currentAttributes.clear();
		}

		if (isList(localName)) {
			if (currentList != null) {
				listStack.add(currentList);
			}
			currentList = new ArrayList<Object>();
		} else if (isDataItem(localName)) {
			if (currentElement != null) {
				elementStack.add(currentElement);
			}
			currentElement = new HashMap<String, Object>();
		} else if (localName == "Data") {
			dataVersion = attributes.getValue("version");
			if (versionOnly) {
				abortParsing();
			} else if (!force && dataVersion == currentVersion
					&& dataVersion.length() > 0) {
				versionMatched = true;
				abortParsing();
			}
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void endElement(String uri, String localName, String qName)
			throws SAXException {
		super.endElement(uri, localName, qName);
		if (isList(localName)) {
			if (currentList != null) {
				if (localName == "Maneuvers") {
					currentElement.put(localName, currentList);
				} else {
					parsedData.put(localName, currentList);
				}

				int index = listStack.size() - 1;
				if (index < 0) {
					currentList = null;
				} else {
					currentList = listStack.get(index);
					listStack.remove(index);
				}
			} else {
				Log.e("spacedock", "ending a list element before starting it");
			}
		} else if (isDataItem(localName)) {
			if (currentElement == null) {
				Log.e("spacedock", "ending an item before starting it");
			} else {
				for (Map.Entry<String, String> entry : currentAttributes
						.entrySet()) {
					currentElement.put(entry.getKey(), entry.getValue());
				}

				if (currentText != null && localName == "Set") {
					String s = currentText.trim();
					currentElement.put("ProduceName", s);
				}

				currentList.add(currentElement);
				int index = elementStack.size() - 1;
				if (index >= 0) {
					currentElement = (Map<String, Object>) elementStack
							.get(index);
					elementStack.remove(index);
				} else {
					currentElement = null;
				}
			}
		} else {
			if (currentText != null && currentElement != null) {
				String trimmed = currentText.trim();
				if (currentAttributes.size() != 0) {
					currentElement.put("ProductName", trimmed);
				} else {
					currentElement.put(localName, trimmed);
				}
			} else {
				Log.i("spacedock", "ending element " + localName
						+ " before starting");
			}
		}

		int stackIndex = elementNameStack.size() - 1;
		if (stackIndex >= 0) {
			elementNameStack.remove(stackIndex);
		}

		currentText = null;
	}

	@Override
	public void characters(char[] ch, int start, int length)
			throws SAXException {
		super.characters(ch, start, length);
		String s = new String(ch, start, length);
		if (currentText == null) {
			currentText = s;
		} else {
			currentText = currentText + s;
		}
	}

	private void abortParsing() {
		// TODO abort parsing
		throw new RuntimeException("version only stop parsing");
	}
}
