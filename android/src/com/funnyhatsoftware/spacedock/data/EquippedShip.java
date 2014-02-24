
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.text.TextUtils;
import android.util.Log;

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

    public boolean getIsResourceSideboard() {
        return getShip() == null;
    }

    public void importUpgrades(Universe universe, JSONObject shipData)
            throws JSONException {
        JSONObject captainObject = shipData.optJSONObject("captain");
        String captainId = captainObject.optString("upgradeId");
        Captain captain = universe.getCaptain(captainId);
        addUpgrade(captain, null, false);
        JSONArray upgrades = shipData.getJSONArray("upgrades");
        for (int i = 0; i < upgrades.length(); ++i) {
            JSONObject upgradeData = upgrades.getJSONObject(i);
            String upgradeId = upgradeData.optString("upgradeId");
            Upgrade upgrade = universe.getUpgrade(upgradeId);
            EquippedUpgrade eu = addUpgrade(upgrade, null, false);
            if (upgradeData.optBoolean("costIsOverridden")) {
                eu.setOverridden(true);
                eu.setOverriddenCost(upgradeData.optInt("overriddenCost"));
            }
        }
        String flagshipId = shipData.optString("flagship");
        if (flagshipId != null) {
            Flagship flagship = universe.getFlagship(flagshipId);
            setFlagship(flagship);
        }
        establishPlaceholders();
    }

    public EquippedUpgrade addUpgrade(Upgrade upgrade) {
        return addUpgrade(upgrade, null, true);
    }

    public EquippedUpgrade addUpgrade(Upgrade upgrade, EquippedUpgrade maybeReplace,
            boolean establishPlaceholders) {
        EquippedUpgrade eu = new EquippedUpgrade();
        if (upgrade == null) {
            return eu;
        }
        String upType = upgrade.getUpType();
        eu.setUpgrade(upgrade);
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

        mUpgrades.add(eu);

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
            if (eu.isPlaceholder() && upType.equals(eu.getUpgrade().getUpType())) {
                return eu;
            }
        }

        return null;
    }

    public void removeUpgrade(EquippedUpgrade eu) {
        removeUpgrade(eu, true);
    }

    private void removeUpgrade(EquippedUpgrade eu, boolean establishPlaceholders) {
        mUpgrades.remove(eu);
        if (establishPlaceholders) {
            establishPlaceholders();
        }
    }

    public int calculateCost() {
        int cost = mShip.getCost();
        for (EquippedUpgrade eu : mUpgrades) {
            cost += eu.calculateCost();
        }
        return cost;
    }

    public String getTitle() {
        if (getIsResourceSideboard()) {
            return getSquad().getResource().getTitle();
        }

        return getShip().getTitle();
    }

    public String getPlainDescription() {
        if (getIsResourceSideboard()) {
            return getSquad().getResource().getTitle();
        }

        return getShip().getPlainDescription();
    }

    String getDescriptiveTitle() {
        if (getIsResourceSideboard()) {
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

    private ArrayList<EquippedUpgrade> getSortedUpgrades() {
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

    public String factionCode() {
        return getShip().factionCode();
    }

    public int getBaseCost() {
        if (getIsResourceSideboard()) {
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
        return v;
    }

    public int getTalent() {
        int v = 0;
        Captain captain = getCaptain();
        if (captain != null) {
            v = captain.getTalent();
        }
        Flagship flagship = getFlagship();
        if (flagship != null) {
            v += flagship.getTalent();
        }
        return v;
    }

    public int getWeapon() {
        int v = 0;
        Ship ship = getShip();
        if (ship != null) {
            v = ship.getWeapon();
        }

        Flagship flagship = getFlagship();
        if (flagship != null) {
            v += flagship.getWeapon();
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
        return v;
    }

    EquippedUpgrade getEquippedCaptain() {
        for (EquippedUpgrade eu : getUpgrades()) {
            Upgrade upgrade = eu.getUpgrade();

            if (upgrade.getUpType().equals("Captain")) {
                return eu;
            }
        }
        return null;
    }

    Captain getCaptain() {
        EquippedUpgrade equippedCaptain = getEquippedCaptain();
        if (equippedCaptain == null) {
            return null;
        }
        return (Captain) equippedCaptain.getUpgrade();
    }

    public void establishPlaceholders() {
        if (getCaptain() == null) {
            String faction = shipFaction();
            if (faction.equals("Federation") || faction.equals("Bajoran")) {
                faction = "Federation";
            }
            Upgrade zcc = Captain.zeroCostCaptain(faction);
            addUpgrade(zcc, null, false);
        }

        establishPlaceholdersForType("Talent", getTalent());
        establishPlaceholdersForType("Crew", getCrew());
        establishPlaceholdersForType("Weapon", getWeapon());
        establishPlaceholdersForType("Tech", getTech());
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
            if (eu.isPlaceholder() && upType.equals(eu.getUpgrade().getUpType())) {
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
            removeUpgrade(eu);
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
        String msg = String.format("Can't add %s to %s", upgrade.getPlainDescription(),
                getPlainDescription());
        String upgradeSpecial = upgrade.getSpecial();
        if (upgradeSpecial.equals("OnlyJemHadarShips")) {
            if (!getShip().isJemhadar()) {
                return new Explanation(false, msg,
                        "This upgrade can only be added to Jem'hadar ships.");
            }
        }
        if (upgradeSpecial.equals("OnlyForKlingonCaptain")) {
            if (!getCaptain().isKlingon()) {
                return new Explanation(false, msg,
                        "This upgrade can only be added to a Klingon Captain.");
            }
        }
        if (upgradeSpecial.equals("OnlyForRomulanScienceVessel")
                || upgradeSpecial.equals("OnlyForRaptorClassShips")) {
            String legalShipClass = upgrade.targetShipClass();
            if (!legalShipClass.equals(getShip().getShipClass())) {
                return new Explanation(false, msg, String.format(
                        "This upgrade can only be installed on ships of class %s.", legalShipClass));
            }
        }

        int limit = upgrade.limitForShip(this);
        if (limit <= 0) {
            String expl;
            if (upgrade.isTalent()) {
                expl = String.format("This ship's captain has no %s upgrade symbols.",
                        upgrade.getUpType());
            } else {
                expl = String.format("This ship has no %s upgrade symbols on its ship card.",
                        upgrade.getUpType());
            }
            return new Explanation(false, msg, expl);
        }
        return new Explanation(true);
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

    public EquippedShip duplicate() {
        // TODO need to implement duplicate
        throw new RuntimeException("Not yet implemented");
    }

    public void removeFlagship() {
        setFlagship(null);
    }

    public Object getFlagshipFaction() {
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
        return allUpgrades.get(0);
    }

    public ArrayList<EquippedUpgrade> allUpgradesOfFaction(
            String string) {
        ArrayList<EquippedUpgrade> allUpgrades = new ArrayList<EquippedUpgrade>();
        for (EquippedUpgrade eu : mUpgrades) {
            if (!eu.getUpgrade().isCaptain()) {
                allUpgrades.add(eu);
            }
        }

        if (allUpgrades.size() > 0) {
            if (allUpgrades.size() > 1) {
                Comparator<EquippedUpgrade> comparator = new Comparator<EquippedUpgrade>() {

                    @Override
                    public int compare(EquippedUpgrade a, EquippedUpgrade b) {
                        int aCost = a.getUpgrade().getCost();
                        int bCost = b.getUpgrade().getCost();
                        if (aCost == bCost) {
                            return 0;
                        } else if (aCost > bCost) {
                            return 1;
                        }
                        return -1;
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
    public static final int SLOT_TYPE_TALENT = 4;
    public static final int SLOT_TYPE_SHIP = 1000;
    public static Class[] CLASS_FOR_SLOT = new Class[] {
            Captain.class,
            Crew.class,
            Weapon.class,
            Tech.class,
            Talent.class,
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

    public EquippedUpgrade getUpgradeAtSlot(int slotType, int slotIndex) {
        Class<?> slotClass = CLASS_FOR_SLOT[slotType];
        int upgradeIndex = getUpgradeIndexOfClass(slotClass, slotIndex);
        if (upgradeIndex < 0) {
            return null;
        }
        return mUpgrades.get(upgradeIndex);
    }

    public void equipUpgrade(int slotType, int slotIndex, String externalId) {
        Upgrade upgrade;
        if (!externalId.isEmpty()) {
            if (slotType == SLOT_TYPE_CAPTAIN) {
                upgrade = Universe.getUniverse().getCaptain(externalId);
            } else {
                upgrade = Universe.getUniverse().getUpgrade(externalId);
            }
        } else {
            // No ID passed, use placeholder
            upgrade = Upgrade.placeholder(CLASS_FOR_SLOT[slotType].getSimpleName());
        }

        EquippedUpgrade newEu = new EquippedUpgrade();
        newEu.setUpgrade(upgrade);
        EquippedUpgrade oldEu = getUpgradeAtSlot(slotType, slotIndex);
        if (oldEu != null) {
            // swap out old upgrade
            mUpgrades.set(mUpgrades.indexOf(oldEu), newEu);
        } else {
            mUpgrades.add(newEu);
        }
    }

    @SuppressWarnings("unused")
    void dump() {
        ArrayList<Class> classes = new ArrayList<Class>();
        for (Class c : CLASS_FOR_SLOT) {
            classes.add(c);
            int i = 0;
            Log.d(TAG, "Equipped " + c.getSimpleName() + "s:");
            for (EquippedUpgrade equippedUpgrade : mUpgrades) {
                if (c.isInstance(equippedUpgrade.getUpgrade())) {
                    if (equippedUpgrade.isPlaceholder()) {
                        Log.d(TAG, "    " + i + ", PLACEHOLDER upgrade is " + equippedUpgrade.getTitle());
                    } else {
                        Log.d(TAG, "    " + i + ", upgrade is " + equippedUpgrade.getTitle());
                    }
                    i++;
                }
            }
        }
    }
}
