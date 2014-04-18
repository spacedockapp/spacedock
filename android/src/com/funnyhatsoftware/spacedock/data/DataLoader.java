
package com.funnyhatsoftware.spacedock.data;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.TreeSet;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;

import android.text.TextUtils;
import android.util.Log;

public class DataLoader extends DefaultHandler {
    Universe universe;
    InputStream xmlInput;
    StringBuilder currentText = new StringBuilder();
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
        String[] a = {
                "Sets", "Upgrades", "Captains", "Ships", "Resources",
                "Maneuvers", "ShipClassDetails", "Flagships"
        };
        Collections.addAll(listElementNames, a);
        String[] b = {
                "Set", "Upgrade", "Captain", "Ship", "Resource",
                "Maneuver", "ShipClassDetail", "Flagship"
        };
        Collections.addAll(itemElementNames, b);

    }

    void loadShipClassDetails() {
        Map<String, ShipClassDetails> details = universe.shipClassDetails;
        @SuppressWarnings("unchecked")
        ArrayList<Object> dataList = (ArrayList<Object>) parsedData.get("ShipClassDetails");
        for (Object oneDataObject : dataList) {
            @SuppressWarnings("unchecked")
            Map<String, Object> oneData = (Map<String, Object>) oneDataObject;
            String externalId = (String) oneData.get("Id");
            ShipClassDetails item = details.get(externalId);
            if (item == null) {
                item = new ShipClassDetails();
            }
            item.update(oneData);
            universe.addShipClassDetails(item);
        }
    }

    public boolean load() throws ParserConfigurationException, SAXException,
            IOException {
        SAXParserFactory spf = SAXParserFactory.newInstance();
        SAXParser sp = spf.newSAXParser();

        XMLReader xr = sp.getXMLReader();

        xr.setContentHandler(this);

        xr.parse(new InputSource(xmlInput));

        loadSets();

        loadShipClassDetails();

        ItemCreator shipHandler = new ItemCreator() {

            @Override
            public SetItem create(String type) {
                return new Ship();
            }

            @Override
            public SetItem get(String externalId) {
                return universe.ships.get(externalId);
            }

            @Override
            public void put(String externalId, SetItem s) {
                universe.ships.put(externalId, (Ship) s);
            }

            @Override
            public void afterUpdate(SetItem s) {
                Ship ship = (Ship) s;
                if (ship.getShipClassDetails() == null) {
                    ShipClassDetails details = universe.getShipClassDetailsByName(ship
                            .getShipClass());
                    if (details != null) {
                        ship.setShipClassDetails(details);
                    }
                }
            }

        };

        loadDataItems("Ships", shipHandler);

        ItemCreator captainHandler = new ItemCreator() {

            @Override
            public SetItem create(String type) {
                return new Captain();
            }

            @Override
            public SetItem get(String externalId) {
                return universe.captains.get(externalId);
            }

            @Override
            public void put(String externalId, SetItem s) {
                universe.captains.put(externalId, (Captain) s);
            }

            @Override
            public void afterUpdate(SetItem s) {
            }

        };

        loadDataItems("Captains", captainHandler);

        ItemCreator upgradeHandler = new ItemCreator() {

            @Override
            public SetItem create(String type) {
                if (type.equalsIgnoreCase("Tech")) {
                    return new Tech();
                }
                if (type.equalsIgnoreCase("Borg")) {
                    return new Borg();
                }
                if (type.equalsIgnoreCase("Talent")) {
                    return new Talent();
                }
                if (type.equalsIgnoreCase("Crew")) {
                    return new Crew();
                }
                return new Weapon();
            }

            @Override
            public SetItem get(String externalId) {
                return universe.upgrades.get(externalId);
            }

            @Override
            public void put(String externalId, SetItem s) {
                universe.upgrades.put(externalId, (Upgrade) s);
            }

            @Override
            public void afterUpdate(SetItem s) {
            }

        };

        loadDataItems("Upgrades", upgradeHandler);

        ItemCreator flagshipHandler = new ItemCreator() {

            @Override
            public SetItem create(String type) {
                return new Flagship();
            }

            @Override
            public SetItem get(String externalId) {
                return universe.flagships.get(externalId);
            }

            @Override
            public void put(String externalId, SetItem s) {
                universe.flagships.put(externalId, (Flagship) s);
            }

            @Override
            public void afterUpdate(SetItem s) {
            }

        };

        loadDataItems("Flagships", flagshipHandler);

        ItemCreator resourceHandler = new ItemCreator() {

            @Override
            public SetItem create(String type) {
                return new Resource();
            }

            @Override
            public SetItem get(String externalId) {
                return universe.resources.get(externalId);
            }

            @Override
            public void put(String externalId, SetItem s) {
                universe.resources.put(externalId, (Resource) s);
            }

            @Override
            public void afterUpdate(SetItem s) {
            }

        };

        loadDataItems("Resources", resourceHandler);

        validateSpecials();

        return true;
    }

    @SuppressWarnings("unchecked")
    private void loadSets() {
        ArrayList<Object> setsList = (ArrayList<Object>) parsedData.get("Sets");
        for (Object oneDataObject : setsList) {
            Map<String, Object> oneData = (Map<String, Object>) oneDataObject;
            String externalId = (String) oneData.get("id");
            Set set = universe.sets.get(externalId);
            if (set == null) {
                set = new Set();
                universe.sets.put(externalId, set);
            }
            set.update(oneData);
        }

        universe.includeAllSets();
    }

    public void validateSpecials() {
        TreeSet<String> allSpecials = universe.getAllSpecials();

        String[] handledSpecials = {
                "BaselineTalentCostToThree",
                "CrewUpgradesCostOneLess",
                "costincreasedifnotromulansciencevessel",
                "WeaponUpgradesCostOneLess",
                "costincreasedifnotbreen",
                "UpgradesIgnoreFactionPenalty",
                "CaptainAndTalentsIgnoreFactionPenalty",
                "PenaltyOnShipOtherThanDefiant",
                "PlusFivePointsNonJemHadarShips",
                "NoPenaltyOnFederationOrBajoranShip",
                "OneDominionUpgradeCostsMinusTwo",
                "OnlyJemHadarShips",
                "PenaltyOnShipOtherThanKeldonClass",
                "addonetechslot",
                "OnlyForRomulanScienceVessel",
                "OnlyForRaptorClassShips",
                "OnlyForKlingonCaptain",
                "AddTwoWeaponSlots",
                "AddTwoCrewSlotsDominionCostBonus",
                "AddsHiddenTechSlot",
                "AddsOneWeaponOneTech",
                "OnlyBajoranCaptain",
                "OnlySpecies8472Ship",
                "OnlyBorgShip",
                "OnlyKazonShip",
                "OnlyVoyager",
                "PlusFiveForNonKazon",
                "PlusFiveOnNonSpecies8472"

        };

        TreeSet<String> unhandledSpecials = new TreeSet<String>(allSpecials);
        unhandledSpecials.removeAll(Arrays.asList(handledSpecials));
        if (unhandledSpecials.size() > 0) {
            Log.e("spacedock", "Unhandled specials: " + TextUtils.join(",", unhandledSpecials));
        }

    }

    interface ItemCreator {
        public SetItem create(String type);

        public SetItem get(String externalId);

        public void put(String externalId, SetItem s);

        public void afterUpdate(SetItem s);
    }

    @SuppressWarnings("unchecked")
    private void loadDataItems(String name, ItemCreator creator) {
        ArrayList<Object> dataList = (ArrayList<Object>) parsedData.get(name);
        for (Object oneDataObject : dataList) {
            Map<String, Object> oneData = (Map<String, Object>) oneDataObject;
            String externalId = (String) oneData.get("Id");
            String type = (String) oneData.get("Type");
            SetItem item = creator.get(externalId);
            if (item == null) {
                item = creator.create(type);
                creator.put(externalId, item);
            }
            item.update(oneData);
            creator.afterUpdate(item);

            String allSetIDs = (String) oneData.get("Set");
            String[] allIds = allSetIDs.split(",");
            for (String setID : allIds) {
                setID = setID.trim();
                Set set = universe.sets.get(setID);
                set.addToSet(item);
            }
        }
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

        if (elementName.equals("Set")) {
            String parentName = parentName();
            if (!parentName.equals("Sets")) {
                return false;
            }
        }
        return true;
    }

    boolean isList(String elementName) {
        if (!listElementNames.contains(elementName)) {
            return false;
        }
        if (elementName.equals("Set")) {
            String parentName = parentName();
            if (!parentName.equals("Sets")) {
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
        } else if (localName.equals("Data")) {
            dataVersion = attributes.getValue("version");
            if (versionOnly) {
                abortParsing();
            } else if (!force && dataVersion.equals(currentVersion)
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
                if (localName.equals("Maneuvers")) {
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

                if (currentText != null && localName.equals("Set")) {
                    String s = currentText.toString().trim();
                    currentElement.put("ProductName", s);
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
                String trimmed = currentText.toString().trim();
                if (currentAttributes.size() != 0) {
                    currentElement.put("ProductName", trimmed);
                } else {
                    currentElement.put(localName, trimmed);
                }
            } else {
                if (!localName.equals("Data")) {
                    Log.i("spacedock", "ending element " + localName
                            + " before starting");
                }
            }
        }

        int stackIndex = elementNameStack.size() - 1;
        if (stackIndex >= 0) {
            elementNameStack.remove(stackIndex);
        }

        currentText.delete(0, currentText.length());
    }

    @Override
    public void characters(char[] ch, int start, int length)
            throws SAXException {
        super.characters(ch, start, length);
        currentText.append(ch, start, length);
    }

    private void abortParsing() {
        // TODO abort parsing
        throw new RuntimeException("version only stop parsing");
    }
}
