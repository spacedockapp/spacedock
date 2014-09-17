
package com.funnyhatsoftware.spacedock.data;

import android.text.TextUtils;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;

public class EquippedShip extends EquippedShipBase {

    private static final String TAG = "EquippedShip";

    public EquippedShip() {
        super();
    }

    public EquippedShip(Ship inShip, boolean establishPlaceholders) {
        super();
        mShip = inShip;
        if (establishPlaceholders) {
            establishPlaceholders();
        }
    }

    public EquippedShip(Ship inShip) {
        super();
        mShip = inShip;
    }

    public boolean isResourceSideboard() {
        return false;
    }

    public String getShipExternalId() {
        if (mShip == null) {
            return "[sideboard]";
        }
        return mShip.getExternalId();
    }

    private EquippedUpgrade addUpgradeInternal(Upgrade upgrade) {
        EquippedUpgrade eu = new EquippedUpgrade();
        if (upgrade == null) {
            return eu;
        }
        eu.setUpgrade(upgrade);
        mUpgrades.add(eu);
        eu.setEquippedShip(this);
        return eu;
    }

    public EquippedUpgrade addUpgrade(Upgrade upgrade) {
        return addUpgrade(upgrade, null, true);
    }

    public EquippedUpgrade addUpgrade(Upgrade upgrade,
            EquippedUpgrade maybeReplace, boolean establishPlaceholders) {
        String upType = upgrade.getUpType();
        if (!upgrade.isPlaceholder()) {
            EquippedUpgrade ph = findPlaceholder(upType);
            if (ph != null) {
                removeUpgrade(ph);
            }
        }
        int limit = upgrade.limitForShip(this);
        int current = equipped(upType);
        if (current == limit) {
            if (maybeReplace == null) {
                maybeReplace = firstUpgrade(upType);
            }

            removeUpgrade(maybeReplace, false);
        }

        EquippedUpgrade eu = addUpgradeInternal(upgrade);

        if (establishPlaceholders) {
            establishPlaceholders();
        }
        return eu;
    }

    private EquippedUpgrade firstUpgrade(String upType) {

        for (EquippedUpgrade eu : mUpgrades) {
            if (upType.equals(eu.getUpgrade().getUpType())) {
                return eu;
            }
        }

        return null;
    }

    private EquippedUpgrade findPlaceholder(String upType) {

        for (EquippedUpgrade eu : mUpgrades) {
            if (eu.isPlaceholder()
                    && upType.equals(eu.getUpgrade().getUpType())) {
                return eu;
            }
        }

        return null;
    }

    public void removeUpgrade(EquippedUpgrade eu) {
        removeUpgrade(eu, true);
    }

    private void removeUpgrade(EquippedUpgrade eu, boolean establishPlaceholders) {
        if (eu != null) {
            mUpgrades.remove(eu);
            eu.setEquippedShip(null);
            if (establishPlaceholders) {
                establishPlaceholders();
            }
        }
    }

    public int calculateCost() {
        int cost = 0;
        if (mShip != null) {
            cost = mShip.getCost();
        }

        for (EquippedUpgrade eu : mUpgrades) {
            cost += eu.calculateCost();
        }

        if (getFlagship() != null) {
            cost += 10;
        }

        return cost;
    }

    public String getTitle() {
        if (isResourceSideboard()) {
            return getSquad().getResource().getTitle();
        }

        return getShip().getDescriptiveTitle();
    }

    public String getPlainDescription() {
        if (isResourceSideboard()) {
            return getSquad().getResource().getTitle();
        }

        return getShip().getPlainDescription();
    }

    String getDescriptiveTitle() {
        if (isResourceSideboard()) {
            return getSquad().getResource().getTitle();
        }

        String s = getShip().getDescriptiveTitle();
        if (getFlagship() != null) {
            s = s + " [FS]";
        }
        return s;
    }

    String getUpgradesDescription() {
        ArrayList<EquippedUpgrade> sortedUpgrades = getSortedUpgrades();
        ArrayList<String> upgradeTitles = new ArrayList<String>();

        for (EquippedUpgrade eu : sortedUpgrades) {
            Upgrade upgrade = eu.getUpgrade();

            if (!upgrade.isPlaceholder()) {
                upgradeTitles.add(upgrade.getTitle());
            }
        }
        return TextUtils.join(", ", upgradeTitles);
    }

    public ArrayList<EquippedUpgrade> getSortedUpgrades() {
        ArrayList<EquippedUpgrade> sortedUpgrades = getUpgrades();
        Comparator<EquippedUpgrade> comparator = new Comparator<EquippedUpgrade>() {

            @Override
            public int compare(EquippedUpgrade arg0, EquippedUpgrade arg1) {
                return arg0.compareTo(arg1);
            }

        };
        Collections.sort(sortedUpgrades, comparator);
        return sortedUpgrades;
    }

    public ArrayList<EquippedUpgrade> getAllUpgradesExceptPlaceholders() {
        ArrayList<EquippedUpgrade> np = new ArrayList<EquippedUpgrade>();
        for (EquippedUpgrade eu : getUpgrades()) {
            if (!eu.isCaptain() && !eu.isPlaceholder()) {
                np.add(eu);
            }
        }
        return np;
    }

    public String factionCode() {
        return getShip().factionCode();
    }

    public int getBaseCost() {
        if (isResourceSideboard()) {
            return getSquad().getResource().getCost();
        }

        return getShip().getCost();
    }

    public int getAttack() {
        int v = 0;
        Ship ship = getShip();
        if (ship != null) {
            v = ship.getAttack();
        }
        Flagship flagship = getFlagship();
        if (flagship != null) {
            v += flagship.getAttack();
        }
        return v;
    }

    public int getAgility() {
        int v = 0;
        Ship ship = getShip();
        if (ship != null) {
            v = ship.getAgility();
        }
        Flagship flagship = getFlagship();
        if (flagship != null) {
            v += flagship.getAgility();
        }
        return v;
    }

    public int getHull() {
        int v = 0;
        Ship ship = getShip();
        if (ship != null) {
            v = ship.getHull();
        }
        Flagship flagship = getFlagship();
        if (flagship != null) {
            v += flagship.getHull();
        }
        return v;
    }

    public int getShield() {
        int v = 0;
        Ship ship = getShip();
        if (ship != null) {
            v = ship.getShield();
        }

        Flagship flagship = getFlagship();
        if (flagship != null) {
            v += flagship.getShield();
        }
        return v;
    }

    public int getTech() {
        int v = 0;
        Ship ship = getShip();
        if (ship != null) {
            v = ship.getTech();
        }

        Flagship flagship = getFlagship();
        if (flagship != null) {
            v += flagship.getTech();
        }
        FleetCaptain fleetCaptain = getFleetCaptain();
        if (null != fleetCaptain) {
            v += fleetCaptain.getTechAdd();
        }

        for (EquippedUpgrade eu : getUpgrades()) {
            Upgrade upgrade = eu.getUpgrade();
            if (upgrade != null) {
                v += upgrade.additionalTechSlots();
            }
        }

        return v;
    }

    public int getBorg() {
        int v = 0;
        Ship ship = getShip();
        if (ship != null) {
            v += ship.getBorg();
        }
        return v;
    }

    public int getCaptainLimit() {
        int v = 0;
        Ship ship = getShip();
        if (ship != null) {
            v += ship.getCaptainLimit();
        } else {
            v = 1;
        }
        return v;
    }

    public int getAdmiralLimit() {
        return getCaptainLimit();
    }

    public int getTalent() {
        int v = 0;
        Captain captain = getCaptain();
        if (captain != null) {
            v = captain.getTalent();
        }
        Admiral admiral = getAdmiral();
        if (null != admiral) {
            v += admiral.getTalent();
        }
        Flagship flagship = getFlagship();
        if (flagship != null) {
            v += flagship.getTalent();
        }
        FleetCaptain fleetCaptain = getFleetCaptain();
        if (null != fleetCaptain) {
            v += fleetCaptain.getTalentAdd();
        }
        return v;
    }

    public int getWeapon() {
        int v = 0;
        Ship ship = getShip();
        if (ship != null) {
            v = ship.getWeapon();
        }

        for (EquippedUpgrade eu : getUpgrades()) {
            Upgrade upgrade = eu.getUpgrade();
            if (upgrade != null) {
                v += upgrade.additionalWeaponSlots();
            }
        }

        Flagship flagship = getFlagship();
        if (flagship != null) {
            v += flagship.getWeapon();
        }

        FleetCaptain fleetCaptain = getFleetCaptain();
        if (null != fleetCaptain) {
            v += fleetCaptain.getWeaponAdd();
        }
        return v;
    }

    public int getCrew() {
        int v = 0;
        Ship ship = getShip();
        if (ship != null) {
            v = ship.getCrew();
        }
        Flagship flagship = getFlagship();
        if (flagship != null) {
            v += flagship.getCrew();
        }
        FleetCaptain fleetCaptain = getFleetCaptain();
        if (null != fleetCaptain){
            v += fleetCaptain.getCrewAdd();
        }
        for (EquippedUpgrade eu : getUpgrades()) {
            Upgrade upgrade = eu.getUpgrade();
            if (upgrade != null) {
                v += upgrade.additionalCrewSlots();
            }
        }
        return v;
    }

    public EquippedUpgrade getEquippedCaptain() {
        for (EquippedUpgrade eu : getUpgrades()) {
            Upgrade upgrade = eu.getUpgrade();

            if (upgrade.getUpType().equals("Captain")) {
                return eu;
            }
        }
        return null;
    }

    public Captain getCaptain() {
        EquippedUpgrade equippedCaptain = getEquippedCaptain();
        if (equippedCaptain == null) {
            return null;
        }
        return (Captain) equippedCaptain.getUpgrade();
    }

    public EquippedUpgrade getEquippedAdmiral() {
        for (EquippedUpgrade eu : getUpgrades()) {
            Upgrade upgrade = eu.getUpgrade();
            if (upgrade.isAdmiral()) {
                return eu;
            }
        }
        return null;
    }

    public Admiral getAdmiral() {
        EquippedUpgrade eu = getEquippedAdmiral();
        if (eu == null) {
            return null;
        }
        return (Admiral) eu.getUpgrade();
    }

    public EquippedUpgrade getEquippedFleetCaptain() {
        for (EquippedUpgrade eu : getUpgrades()) {
            Upgrade upgrade = eu.getUpgrade();
            if (upgrade.isFleetCaptain()) {
                return eu;
            }
        }
        return null;
    }

    public FleetCaptain getFleetCaptain() {
        EquippedUpgrade eu = getEquippedFleetCaptain();
        if (eu == null) {
            return null;
        }
        return (FleetCaptain) eu.getUpgrade();
    }

    public void establishPlaceholders() {
        if (getCaptainLimit() > 0) {
            if (getCaptain() == null) {
                if (isResourceSideboard()) {
                    Upgrade zcc = Captain.zeroCostCaptain("Federation");
                    addUpgrade(zcc, null, false);
                } else {
                    Upgrade zcc = Captain.zeroCostCaptainForShip(getShip());
                    addUpgrade(zcc, null, false);
                }
            }
            establishPlaceholdersForType("Admiral", getCaptainLimit());
        }
        establishPlaceholdersForType("Talent", getTalent());
        establishPlaceholdersForType("Crew", getCrew());
        establishPlaceholdersForType("Weapon", getWeapon());
        establishPlaceholdersForType("Tech", getTech());
        establishPlaceholdersForType("Borg", getBorg());
    }

    private void establishPlaceholdersForType(String upType, int limit) {
        int current = equipped(upType);
        if (current > limit) {
            removeOverLimit(upType, current, limit);
        } else {
            for (int i = current; i < limit; ++i) {
                Upgrade upgrade = Upgrade.placeholder(upType);
                addUpgrade(upgrade, null, false);
            }
        }
    }

    private void removeOverLimit(String upType, int current, int limit) {
        int amountToRemove = current - limit;
        removeUpgradesOfType(upType, amountToRemove);
    }

    private void removeUpgradesOfType(String upType, int targetCount) {
        ArrayList<EquippedUpgrade> onesToRemove = new ArrayList<EquippedUpgrade>();
        ArrayList<EquippedUpgrade> upgrades = getSortedUpgrades();

        for (EquippedUpgrade eu : upgrades) {
            if (eu.isPlaceholder()
                    && upType.equals(eu.getUpgrade().getUpType())) {
                onesToRemove.add(eu);
            }

            if (onesToRemove.size() == targetCount) {
                break;
            }
        }

        if (onesToRemove.size() != targetCount) {
            for (EquippedUpgrade eu : upgrades) {
                if (upType.equals(eu.getUpgrade().getUpType())) {
                    onesToRemove.add(eu);
                }

                if (onesToRemove.size() == targetCount) {
                    break;
                }
            }
        }

        for (EquippedUpgrade eu : onesToRemove) {
            removeUpgrade(eu, false);
        }

    }

    private int equipped(String upType) {
        int count = 0;
        ArrayList<EquippedUpgrade> upgrades = getSortedUpgrades();

        for (EquippedUpgrade eu : upgrades) {
            if (upType.equals(eu.getUpgrade().getUpType())) {
                count += 1;
            }

        }
        return count;
    }

    public String shipFaction() {
        Ship ship = getShip();
        if (ship == null) {
            return "Federation";
        }
        return ship.getFaction();
    }

    public Explanation canAddUpgrade(Upgrade upgrade) {
        String msg = String.format("Can't add %s to %s",
                upgrade.getPlainDescription(), getPlainDescription());
        if (isFighterSquadron()) {
            return new Explanation(msg,
                    "Fighter Squadrons cannot accept upgrades.");
        }
        String upgradeSpecial = upgrade.getSpecial();
        Ship ship = getShip();
        if (upgradeSpecial.equals("OnlyJemHadarShips")) {
            if (!ship.isJemhadar()) {
                return new Explanation(msg,
                        "This upgrade can only be added to Jem'hadar ships.");
            }
        }

        if (upgradeSpecial.equals("OnlyTholianShip")) {
            if (!ship.isTholian()) {
                return new Explanation(msg,
                        "This upgrade can only be added to Tholian ships.");
            }
        }
        if (upgradeSpecial.equals("OnlyVoyager")) {
            if (!ship.isVoyager()) {
                return new Explanation(msg,
                        "This upgrade can only be added to the U.S.S Voyager.");
            }
        }
        if (upgradeSpecial.equals("PhaserStrike") || "OnlyHull3OrLess".equals(upgradeSpecial)) {
            if (!ship.isHullThreeOrLess()) {
                return new Explanation(msg,
                        "This upgrade may only be purchased for a ship with a Hull value of 3 or less.");
            }
        }
        if (upgradeSpecial.equals("OnlyForRomulanScienceVessel")
                || upgradeSpecial.equals("OnlyForRaptorClassShips")) {
            String legalShipClass = upgrade.targetShipClass();
            if (!legalShipClass.equals(ship.getShipClass())) {
                return new Explanation(
                        msg,
                        String.format(
                                "This upgrade can only be installed on ships of class %s.",
                                legalShipClass)
                );
            }
        }
        if ("OnlyBorgShip".equals(upgradeSpecial)) {
            if (!ship.isBorg()) {
                return new Explanation(msg, "This upgrade can only be added to Borg ships.");
            }
        }
        if ("OnlyFederationShip".equals(upgradeSpecial)) {
            if (!ship.isFederation()) {
                return new Explanation(msg, "This upgrade can only be added to Federation ships.");
            }
        }
        if ("OnlyBattleshipOrCruiser".equals(upgradeSpecial)) {
            if (!ship.isBattleshipOrCruiser()) {
                return new Explanation(msg, "This upgrade can only be purchased for a Jem'Hadar Battleship or Battle Cruiser.");
            }
        }
        if ("combat_vessel_variant_71508".equals(upgradeSpecial)
                || "only_suurok_class_limited_weapon_hull_plus_1".equals(upgradeSpecial)) {
            if (!ship.isSuurok()) {
                return new Explanation(msg, "This upgrade can only be purchased for a Suurok Class Ship.");
            }
            if (null != containsUpgrade(upgrade)) {
                return new Explanation(msg, "This upgrade can only be added once per ship.");
            }
        }
        if (upgradeSpecial.equals("OnlyKazonShip")) {
            if (!ship.isKazon()) {
                return new Explanation(msg,
                        "This upgrade can only be added to Kazon ships.");
            }
        }
        if ("NoMoreThanOnePerShip".equals(upgradeSpecial)) {
            if (null != containsUpgrade(upgrade)) {
                return new Explanation(msg, "This upgrade can only be added once per ship.");
            }
        }
        if ("ony_federation_ship_limited".equals(upgradeSpecial)) {
            if (null != containsUpgrade(upgrade)) {
                return new Explanation(msg, "This upgrade can only be added once per ship.");
            }
            if (!ship.isFederation()) {
                return new Explanation(msg, "This upgrade can only be added to a federation ship.");
            }
        }
        Captain captain = getCaptain();
        if (!"lore_71522".equals(captain.getSpecial()) || !upgrade.isTalent()) {
            if (upgradeSpecial.equals("OnlyForKlingonCaptain")) {
                if (!captain.isKlingon()) {
                    return new Explanation(msg,
                            "This upgrade can only be added to a Klingon Captain.");
                }
            }
            if (upgradeSpecial.equals("OnlyBajoranCaptain")) {
                if (!captain.isBajoran()) {
                    return new Explanation(msg,
                            "This upgrade can only be added to a Bajoran Captain.");
                }
            }

            if (upgradeSpecial.equals("OnlySpecies8472Ship")) {
                if (!ship.isSpecies8472()) {
                    return new Explanation(msg,
                            "This upgrade can only be added to Species 8472 ships.");
                }
            }
            if (upgradeSpecial.equals("OnlyBorgCaptain")) {
                if (!captain.isBorgFaction()) {
                    return new Explanation(msg,
                            "This Upgrade may only be purchased for a Borg Captain.");
                }
            }
            if (upgradeSpecial.equals("OnlyDominionCaptain")) {
                if (!captain.isDominion()) {
                    return new Explanation(msg, "This Upgrade may only be purchased for a Dominion Captain");
                }
            }
            if (upgradeSpecial.equals("VulcanHighCommand")) {
                if (!ship.isVulcan() || !captain.isVulcan()) {
                    return new Explanation(msg,
                            "This upgrade may only be purchased for a Vulcan Captain on a Vulcan ship.");
                }
            }
            if ("only_vulcan_ship".equals(upgradeSpecial)) {
                if (!ship.isVulcan()) {
                    return new Explanation(msg,
                            "This upgrade may only be purchased for a Vulcan ship.");
                }
            }
        }

        if (upgradeSpecial.equals("OnlyTholianCaptain")) {
            if (!captain.isTholian()) {
                return new Explanation(msg,
                        "This upgrade can only be added to a Tholian Captain.");
            }
        }

        if ("Borg Scout Cube".equalsIgnoreCase(ship.getShipClass())
                && upgrade.isBorg() && upgrade.getCost() > 5){
            return new Explanation(msg,
                    "Cannot equip a Borg upgrade with cost greater than 5 to this ship.");
        }

        int limit = upgrade.limitForShip(this);
        if (limit <= 0) {
            String expl;
            if (upgrade.isTalent()) {
                expl = String.format(
                        "This ship's captain has no %s upgrade symbols.",
                        upgrade.getUpType());
            } else {
                expl = String
                        .format("This ship has no %s upgrade symbols on its ship card.",
                                upgrade.getUpType());
            }
            return new Explanation(msg, expl);
        }
        return Explanation.SUCCESS;
    }

    public Explanation canAddFleetCaptain(FleetCaptain fleetCaptain) {
        Captain captain = getCaptain();
        String msg = String.format("Can't make %s the Fleet Captain", captain.getTitle());
        if (!captain.getUnique()) {
            String info = "You may not assign a non-unique Captain as your Fleet Captain";
            return new Explanation(msg, info);
        }
        String fleetCaptainFaction = fleetCaptain.getFaction();
        if (!fleetCaptainFaction.equals(Constants.INDEPENDENT)) {
            if (!DataUtils.factionsMatch(getShip(), fleetCaptain)) {
                String info = "The ship's faction must be the same as the Fleet Captain.";
                return new Explanation(msg, info);
            }
            if (!DataUtils.factionsMatch(captain, fleetCaptain)) {
                String info = "The Captain's faction must be the same as the Fleet Captain.";
                return new Explanation(msg, info);
            }
        }
        return Explanation.SUCCESS;
    }

    public EquippedUpgrade containsUpgrade(Upgrade theUpgrade) {
        for (EquippedUpgrade eu : mUpgrades) {
            if (eu.getUpgrade() == theUpgrade) {
                return eu;
            }
        }
        return null;
    }

    public EquippedUpgrade containsUpgradeWithName(String theName) {
        for (EquippedUpgrade eu : mUpgrades) {
            if (eu.getUpgrade().getTitle().equals(theName)) {
                return eu;
            }
        }
        return null;
    }

    public EquippedUpgrade containsUniqueUpgradeWithName(String theName) {
        for (EquippedUpgrade eu : mUpgrades) {
            Upgrade upgrade = eu.getUpgrade();
            if (upgrade.getUnique() && upgrade.getTitle().equals(theName)) {
                return eu;
            }
        }
        return null;
    }

    public EquippedUpgrade containsMirrorUniverseUniqueUpgradeWithName(String theName) {
        for (EquippedUpgrade eu : mUpgrades) {
            Upgrade upgrade = eu.getUpgrade();
            if (upgrade.getMirrorUniverseUnique() && upgrade.getTitle().equals(theName)) {
                return eu;
            }
        }
        return null;
    }

    public EquippedShip duplicate() {
        // TODO need to implement duplicate
        throw new RuntimeException("Not yet implemented");
    }

    public void removeFlagship() {
        setFlagship(null);
    }

    public void removeFleetCaptain() {
        EquippedUpgrade fc = getEquippedFleetCaptain();
        if (fc != null) {
            removeUpgrade(fc);
        }
    }

    public String getFlagshipFaction() {
        Flagship flagship = getFlagship();
        if (flagship == null) {
            return "";
        }
        return flagship.getFaction();
    }

    public EquippedUpgrade mostExpensiveUpgradeOfFaction(String faction) {
        ArrayList<EquippedUpgrade> allUpgrades = allUpgradesOfFaction(faction);
        if (allUpgrades.isEmpty()) {
            return null;
        }
        EquippedUpgrade mostExpensive = allUpgrades.get(0);
        return mostExpensive.isPlaceholder() ? null : mostExpensive;
    }

    public EquippedUpgrade mostExpensiveUpgradeOfType(String upType) {
        return mostExpensiveUpgradeOfFactionAndType(null, upType);
    }

    public EquippedUpgrade mostExpensiveUpgradeOfFactionAndType(String faction,
            String upType) {
        ArrayList<EquippedUpgrade> allUpgrades = allUpgradesOfFactionAndType(
                faction, upType);
        if (allUpgrades.isEmpty()) {
            return null;
        }
        EquippedUpgrade mostExpensive = allUpgrades.get(0);
        return mostExpensive.isPlaceholder() ? null : mostExpensive;
    }

    public ArrayList<EquippedUpgrade> allUpgradesOfFaction(String faction) {
        return allUpgradesOfFactionAndType(faction, null);
    }

    public ArrayList<EquippedUpgrade> allUpgradesOfType(String upType) {
        return allUpgradesOfFactionAndType(null, upType, false);
    }

    public ArrayList<EquippedUpgrade> allUpgradesOfFactionAndType(
            String faction, String upType) {
        return allUpgradesOfFactionAndType(faction, upType, true);
    }

    public ArrayList<EquippedUpgrade> allUpgradesOfFactionAndType(
            String faction, String upType, boolean includePlaceholders) {
        ArrayList<EquippedUpgrade> allUpgrades = new ArrayList<EquippedUpgrade>();
        for (EquippedUpgrade eu : mUpgrades) {
            if (!eu.getUpgrade().isCaptain()) {
                if (upType == null
                        || upType.equals(eu.getUpgrade().getUpType())) {
                    if (faction == null
                            || faction.equals(eu.getUpgrade().getFaction())) {
                        if (includePlaceholders || !eu.isPlaceholder()) {
                            allUpgrades.add(eu);
                        }
                    }
                }
            }
        }

        if (allUpgrades.size() > 0) {
            if (allUpgrades.size() > 1) {
                Comparator<EquippedUpgrade> comparator = new Comparator<EquippedUpgrade>() {

                    @Override
                    public int compare(EquippedUpgrade a, EquippedUpgrade b) {
                        if (a.isPlaceholder() != b.isPlaceholder()) {
                            if (a.isPlaceholder()) {
                                return 1;
                            }
                            return 0;
                        }
                        int aCost = a.getUpgrade().getCost();
                        int bCost = b.getUpgrade().getCost();
                        if (aCost == bCost) {
                            return 0;
                        } else if (aCost > bCost) {
                            return -1;
                        }
                        return 1;
                    }

                };
                Collections.sort(allUpgrades, comparator);
            }
        }
        return allUpgrades;
    }

    // ////////////////////////////////////////////////////////////////
    // Slot management
    // ////////////////////////////////////////////////////////////////

    public static final int SLOT_TYPE_INVALID = -1;
    public static final int SLOT_TYPE_CAPTAIN = 0;
    public static final int SLOT_TYPE_CREW = 1;
    public static final int SLOT_TYPE_WEAPON = 2;
    public static final int SLOT_TYPE_TECH = 3;
    public static final int SLOT_TYPE_BORG = 4;
    public static final int SLOT_TYPE_TALENT = 5;
    public static final int SLOT_TYPE_FLAGSHIP = 6;
    public static final int SLOT_TYPE_ADMIRAL = 7;
    public static final int SLOT_TYPE_FLEET_CAPTAIN = 8;
    public static final int SLOT_TYPE_SHIP = 1000;

    public static Class[] CLASS_FOR_SLOT = new Class[] {
            Captain.class,
            Crew.class, Weapon.class, Tech.class, Borg.class, Talent.class,
            Flagship.class, Admiral.class, FleetCaptain.class
    };

    private int getUpgradeIndexOfClass(Class slotClass, int slotIndex) {
        for (int i = 0; i < mUpgrades.size(); i++) {
            EquippedUpgrade equippedUpgrade = mUpgrades.get(i);
            if (equippedUpgrade.getUpgrade().getClass() == slotClass) {
                slotIndex--;
                if (slotIndex < 0) {
                    return i;
                }
            }
        }
        return -1;
    }

    public int getUpgradeIndexAtSlot(int slotType, int slotIndex) {
        Class<?> slotClass = CLASS_FOR_SLOT[slotType];
        return getUpgradeIndexOfClass(slotClass, slotIndex);
    }

    public EquippedUpgrade getUpgradeAtSlot(int slotType, int slotIndex) {
        int upgradeIndex = getUpgradeIndexAtSlot(slotType, slotIndex);
        if (upgradeIndex < 0) {
            return null;
        }
        return mUpgrades.get(upgradeIndex);
    }

    public Explanation trySetShip(Squad squad, String externalId) {
        if (externalId == null) {
            // Abandon ship!
            squad.removeEquippedShip(this);
            return Explanation.SUCCESS;
        }

        if (externalId.equals(getShip().getExternalId())) {
            // nothing to do
            return Explanation.SUCCESS;
        }

        Ship ship = Universe.getUniverse().getShip(externalId);
        Explanation explanation = squad.canAddShip(ship);
        if (!explanation.canAdd) {
            return explanation; // disallowed, abort!
        }
        setShip(ship);

        // TODO: consider swapping zero cost captain for new faction?
        establishPlaceholders();

        return Explanation.SUCCESS;
    }

    public Explanation tryEquipFlagship(Squad squad, String externalId) {
        if (externalId == null) {
            squad.removeFlagship();
        } else {
            Flagship flagship = Universe.getUniverse().getFlagship(externalId);
            if (!flagship.compatibleWithFaction(shipFaction())) {
                return new Explanation("Failed to add Flagship.",
                        flagship.getPlainDescription()
                                + " not compatible with ship faction "
                                + shipFaction());
            }
            squad.removeFlagship();
            setFlagship(flagship);
        }

        // slot counts may have changed, refresh placeholders + prune slots to
        // new count
        establishPlaceholders();

        return Explanation.SUCCESS;
    }

    public Explanation tryEquipFleetCaptain(Squad squad, String externalId) {
        if (externalId == null) {
            squad.removeFleetCaptain();
        } else {
            FleetCaptain fleetCaptain = Universe.getUniverse().getFleetCaptain(externalId);
            Explanation explanation = canAddFleetCaptain(fleetCaptain);
            if (!explanation.canAdd) {
                return explanation;
            }
            squad.removeFleetCaptain();
            addUpgrade(fleetCaptain);
        }

        // slot counts may have changed, refresh placeholders + prune slots to
        // new count
        establishPlaceholders();

        return Explanation.SUCCESS;
    }

    public Explanation tryEquipUpgrade(Squad squad, int slotType,
            int slotIndex, String externalId) {
        Upgrade upgrade;
        if (externalId != null && !externalId.isEmpty()) {
            if (slotType == SLOT_TYPE_CAPTAIN) {
                upgrade = Universe.getUniverse().getCaptain(externalId);
                Explanation explanation = squad.canAddCaptain(
                        (Captain) upgrade, this);
                if (!explanation.canAdd) {
                    return explanation; // disallowed, abort!
                }
            } else if (SLOT_TYPE_FLEET_CAPTAIN == slotType) {
                FleetCaptain fleetCaptain = Universe.getUniverse().getFleetCaptain(externalId);
                Explanation explanation = canAddFleetCaptain(fleetCaptain);
                if (!explanation.canAdd) {
                    return explanation; // disallowed, abort!
                }
                upgrade = fleetCaptain;
            } else {
                upgrade = SLOT_TYPE_ADMIRAL == slotType ? Universe
                        .getUniverse().getAdmiral(externalId) : Universe
                        .getUniverse().getUpgrade(externalId);
                Explanation explanation = squad.canAddUpgrade(upgrade, this);
                if (!explanation.canAdd) {
                    return explanation; // disallowed, abort!
                }
            }
        } else {
            // No ID passed, use placeholder
            upgrade = Upgrade.placeholder(CLASS_FOR_SLOT[slotType]
                    .getSimpleName());
        }

        EquippedUpgrade newEu = new EquippedUpgrade();
        newEu.setUpgrade(upgrade);
        int oldEuIndex = getUpgradeIndexAtSlot(slotType, slotIndex);

        if (oldEuIndex >= 0) {
            // swap out old upgrade
            EquippedUpgrade oldUpgrade = mUpgrades.get(oldEuIndex);
            oldUpgrade.setEquippedShip(null);
            mUpgrades.set(oldEuIndex, newEu);
        } else {
            mUpgrades.add(newEu);
        }
        newEu.setEquippedShip(this);

        // slot counts may have changed, refresh placeholders + prune slots to
        // new count
        establishPlaceholders();

        return Explanation.SUCCESS;
    }

    public void dump() {
        for (Class c : CLASS_FOR_SLOT) {
            int i = 0;
            Log.d(TAG, "Equipped " + c.getSimpleName() + "s:");
            for (EquippedUpgrade equippedUpgrade : mUpgrades) {
                if (c.isInstance(equippedUpgrade.getUpgrade())) {
                    if (equippedUpgrade.isPlaceholder()) {
                        Log.d(TAG, "    " + i + ", PLACEHOLDER upgrade is "
                                + equippedUpgrade.getTitle());
                    } else {
                        Log.d(TAG, "    " + i + ", upgrade is "
                                + equippedUpgrade.getTitle());
                    }
                    i++;
                }
            }
        }
    }

    public void getFactions(HashSet<String> factions) {
        if (mShip != null) {
            String faction = mShip.getFaction();
            if (faction != null) {
                factions.add(faction);
            }
            for (EquippedUpgrade eu : mUpgrades) {
                faction = eu.getFaction();
                if (faction != null) {
                    factions.add(faction);
                }
            }
        }
    }

    public String getFaction() {
        if (mShip == null) {
            return "";
        }
        return mShip.getFaction();
    }

    public JSONObject asJSON() throws JSONException {
        JSONObject o = new JSONObject();
        Ship ship = getShip();
        if (ship == null) {
            o.put(JSONLabels.JSON_LABEL_SIDEBOARD, true);
        } else {
            o.put(JSONLabels.JSON_LABEL_SHIP_ID, ship.getExternalId());
            o.put(JSONLabels.JSON_LABEL_SHIP_TITLE, ship.getTitle());
            Flagship flagship = getFlagship();
            if (flagship != null) {
                o.put(JSONLabels.JSON_LABEL_FLAGSHIP, flagship.getExternalId());
            }
        }
        o.put(JSONLabels.JSON_LABEL_CAPTAIN, getEquippedCaptain().asJSON());
        ArrayList<EquippedUpgrade> sortedUpgrades = getSortedUpgrades();
        JSONArray upgrades = new JSONArray();
        int index = 0;
        for (EquippedUpgrade upgrade : sortedUpgrades) {
            if (!upgrade.isPlaceholder() && !upgrade.isCaptain()) {
                upgrades.put(index++, upgrade.asJSON());
            }
        }
        o.put(JSONLabels.JSON_LABEL_UPGRADES, upgrades);
        return o;
    }

    public void importUpgrades(Universe universe, JSONObject shipData,
            boolean strict) throws JSONException {
        JSONObject captainObject = shipData
                .optJSONObject(JSONLabels.JSON_LABEL_CAPTAIN);
        if (captainObject != null) {
            String captainId = captainObject
                    .optString(JSONLabels.JSON_LABEL_UPGRADE_ID);
            Captain captain = universe.getCaptain(captainId);
            addUpgrade(captain, null, false);
        } else if (strict) {
            throw new RuntimeException("Can't find captain object.");
        }

        String flagshipId = shipData.optString(JSONLabels.JSON_LABEL_FLAGSHIP);
        if (flagshipId.length() > 0) {
            Flagship flagship = universe.getFlagship(flagshipId);
            if (strict && flagship == null) {
                throw new RuntimeException("Can't find flagship '" + flagshipId
                        + "'");
            }
            setFlagship(flagship);
        }

        JSONArray upgrades = shipData
                .optJSONArray(JSONLabels.JSON_LABEL_UPGRADES);
        if (upgrades != null) {
            for (int i = 0; i < upgrades.length(); ++i) {
                JSONObject upgradeData = upgrades.getJSONObject(i);
                String upgradeId = upgradeData
                        .optString(JSONLabels.JSON_LABEL_UPGRADE_ID);
                Upgrade upgrade = universe.getUpgradeLikeItem(upgradeId);
                if (upgrade != null) {
                    EquippedUpgrade eu = addUpgradeInternal(upgrade);
                    if (upgradeData
                            .optBoolean(JSONLabels.JSON_LABEL_COST_IS_OVERRIDDEN)) {
                        eu.setOverridden(true);
                        eu.setOverriddenCost(upgradeData
                                .optInt(JSONLabels.JSON_LABEL_OVERRIDDEN_COST));
                    }
                } else if (strict) {
                    throw new RuntimeException("Can't find upgrade '" + upgradeId
                            + "'");
                }
            }
        }

        establishPlaceholders();
    }

    public boolean isFighterSquadron() {
        return mShip != null && mShip.isFighterSquadron();
    }

}
