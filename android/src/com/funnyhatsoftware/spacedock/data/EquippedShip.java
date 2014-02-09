
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

    /*
     * -(NSDictionary*)asJSON { NSMutableDictionary* json =
     * [[NSMutableDictionary alloc] init]; DockShip* ship = self.ship; if (ship
     * == nil) { [json setObject: @YES forKey: @"sideboard"]; } else { [json
     * setObject: ship.externalId forKey: @"shipId"]; [json setObject:
     * ship.title forKey: @"shipTitle"]; DockFlagship* flagship = self.flagship;
     * if (flagship != nil) { [json setObject: flagship.externalId forKey:
     * @"flagship"]; } } [json setObject: [self.equippedCaptain asJSON] forKey:
     * @"captain"]; NSArray* upgrades = [self sortedUpgrades]; if
     * (upgrades.count > 0) { NSMutableArray* upgradesArray = [[NSMutableArray
     * alloc] initWithCapacity: upgrades.count]; for (DockEquippedUpgrade* eu in
     * upgrades) { if (![eu isPlaceholder] && ![eu.upgrade isCaptain]) {
     * [upgradesArray addObject: [eu asJSON]]; } } [json setObject:
     * upgradesArray forKey: @"upgrades"]; } return [NSDictionary
     * dictionaryWithDictionary: json]; }
     */

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
        // TODO establish placeholders
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

}
