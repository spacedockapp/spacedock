
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.text.TextUtils;

public class EquippedShip extends EquippedShipBase {

    public EquippedShip() {
    }

    public EquippedShip(Ship inShip) {
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
        addUpgrade(captain);
        JSONArray upgrades = shipData.getJSONArray("upgrades");
        for (int i = 0; i < upgrades.length(); ++i) {
            JSONObject upgradeData = upgrades.getJSONObject(i);
            String upgradeId = upgradeData.optString("upgradeId");
            Upgrade upgrade = universe.getUpgrade(upgradeId);
            EquippedUpgrade eu = addUpgrade(upgrade);
            if (upgradeData.optBoolean("costIsOverridden")) {
                eu.setOverridden(true);
                eu.setOverriddenCost(upgradeData.optInt("overriddenCost"));
            }
        }
    }

    public EquippedUpgrade addUpgrade(Upgrade upgrade) {
        EquippedUpgrade eu = new EquippedUpgrade();
        eu.setUpgrade(upgrade);
        mUpgrades.add(eu);
        return eu;
    }

    public EquippedUpgrade addUpgrade(Upgrade upgrade, EquippedUpgrade maybeReplace,
            boolean establishPlaceholders) {
        EquippedUpgrade eu = new EquippedUpgrade();
        eu.setUpgrade(upgrade);
        mUpgrades.add(eu);
        return eu;
    }

    public void removeUpgrade(EquippedUpgrade eu) {
        mUpgrades.remove(eu);
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

    public String factionCode()
    {
        return getShip().factionCode();
    }

    public int getBaseCost()
    {
        if (getIsResourceSideboard()) {
            return getSquad().getResource().getCost();
        }

        return getShip().getCost();
    }

    public int getAttack()
    {
        int attack = getShip().getAttack();
        Flagship flagship = getFlagship();
        if (flagship != null) {
            attack += flagship.getAttack();
        }
        return attack;
    }

    public int getAgility()
    {
        int v = getShip().getAgility();
        Flagship flagship = getFlagship();
        if (flagship != null) {
            v += flagship.getAgility();
        }
        return v;
    }

    public int getHull()
    {
        int v = getShip().getHull();
        Flagship flagship = getFlagship();
        if (flagship != null) {
            v += flagship.getHull();
        }
        return v;
    }

    public int getShield()
    {
        int v = getShip().getShield();
        Flagship flagship = getFlagship();
        if (flagship != null) {
            v += flagship.getShield();
        }
        return v;
    }

    public int getTech() {
        int v = getShip().getTech();
        Flagship flagship = getFlagship();
        if (flagship != null) {
            v += flagship.getTech();
        }
        return v;
    }

    public int getTalent() {
        int v = getCaptain().getTalent();
        Flagship flagship = getFlagship();
        if (flagship != null) {
            v += flagship.getTalent();
        }
        return v;
    }

    public int getWeapon() {
        int v = getShip().getWeapon();
        Flagship flagship = getFlagship();
        if (flagship != null) {
            v += flagship.getWeapon();
        }
        return v;
    }

    public int getCrew() {
        int v = getShip().getCrew();
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
        return (Captain) getEquippedCaptain().getUpgrade();
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
        // TODO Auto-generated method stub
        return new Explanation(false, "foo", "bar");
    }

    public EquippedUpgrade containsUpgrade(Upgrade theUpgrade) {
        // TODO Auto-generated method stub
        return null;
    }

    public EquippedUpgrade containsUpgradeWithName(String theName) {
        // TODO Auto-generated method stub
        return null;
    }

    public EquippedShip duplicate() {
        // TODO Auto-generated method stub
        return null;
    }

    public void removeFlagship() {
        setFlagship(null);
    }

    public Object getFlagshipFaction() {
        // TODO Auto-generated method stub
        return null;
    }

    public EquippedUpgrade mostExpensiveUpgradeOfFaction(String string) {
        // TODO Auto-generated method stub
        return null;
    }

    public ArrayList<EquippedUpgrade> allUpgradesOfFaction(
            String string) {
        // TODO Auto-generated method stub
        return null;
    }

    // ////////////////////////////////////////////////////////////////
    // Slot management
    // ////////////////////////////////////////////////////////////////
    private int getUpgradeIndexOfClass(Class slotClass, int slotIndex) {
        for (int i = 0; i < mUpgrades.size(); i++) {
            EquippedUpgrade equippedUpgrade = mUpgrades.get(i);
            if (equippedUpgrade.getUpgrade().getClass() == slotClass) {
                slotIndex--;
                if (slotIndex < 0)
                    return i;
            }
        }
        return -1;
    }

    public EquippedUpgrade getUpgradeAtSlot(Class slotClass, int slotIndex) {
        int upgradeIndex = getUpgradeIndexOfClass(slotClass, slotIndex);
        if (upgradeIndex < 0)
            return null;
        return mUpgrades.get(upgradeIndex);
    }

    public void equipUpgrade(Upgrade upgrade, int slotIndex) {
        EquippedUpgrade eu = new EquippedUpgrade();
        eu.setUpgrade(upgrade);
        upgrade.mEquippedUpgrades.add(eu);

        Class slotClass = upgrade.getClass();
        int oldUpgradeIndex = getUpgradeIndexOfClass(slotClass, slotIndex);

        if (oldUpgradeIndex >= 0) {
            // replace old

            EquippedUpgrade oldEu = mUpgrades.get(oldUpgradeIndex);
            // existing upgrade to replace
            Upgrade oldU = oldEu.getUpgrade();
            oldU.getEquippedUpgrades().remove(oldEu);
            oldEu.setEquippedShip(null);
            oldEu.setUpgrade(null);

            mUpgrades.set(oldUpgradeIndex, eu);
        } else {
            // simply add
            mUpgrades.add(eu);
        }
    }

}
