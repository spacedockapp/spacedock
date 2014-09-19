
package com.funnyhatsoftware.spacedock.data;

import java.util.Map;
import java.util.TreeMap;

public class Sideboard extends SideboardBase {
    
    private static Ship sNullShip;

    public static Sideboard sideboard() {
        Sideboard sideboard = new Sideboard();
        sideboard.establishPlaceholders();
        return sideboard;
    }

    @Override
    public Ship getShip() {
        if (sNullShip == null) {
            sNullShip = new Ship();
            Map<String, Object> data = new TreeMap<String, Object>();
            sNullShip.update(data);
            ShipClassDetails nullDetails = new ShipClassDetails();
            nullDetails.update(data);
            sNullShip.setShipClassDetails(nullDetails);
        }
        return sNullShip;
    }

    @Override
    public int calculateCost() {
        Resource r = Resource.sideboardResource();
        return r.getCost();
    }

    @Override
    public int getTalent() {
        return 1;
    }

    @Override
    public int getTech() {
        return 1;
    }

    @Override
    public int getWeapon() {
        return 1;
    }

    @Override
    public int getCrew() {
        return 1;
    }

    @Override
    public int getBorg() {
        return 0;
    }

    @Override
    public int getCaptainLimit() {
        return 1;
    }

    public int calculateBaseCost() {
        int cost = 0;

        for (EquippedUpgrade eu : mUpgrades) {
            cost += eu.getCost();
        }

        return cost;
    }

    @Override
    public Explanation canAddUpgrade(Upgrade upgrade, boolean addingNew) {
        int currentCost = calculateBaseCost();
        if (currentCost + upgrade.getCost() > 20) {
            String msg = String.format("Can't add %s to %s", upgrade.getPlainDescription(),
                    getPlainDescription());
            String expl;
            expl = String.format("Adding an item of cost %d would exceed limit of 20.",
                    upgrade.getCost());
            return new Explanation(msg, expl);
        }
        if (upgrade.getUpType().equals("Borg")) {
            String msg = String.format("Can't add %s to %s", upgrade.getPlainDescription(),
                    getPlainDescription());
            String expl;
            expl = String.format("This ship has no %s upgrade symbols on its ship card.",
                    upgrade.getUpType());
            return new Explanation(msg, expl);
        }
        return Explanation.SUCCESS;
    }

    public int baseCost() {
        int cost = 0;
        for (EquippedUpgrade eu : mUpgrades) {
            cost += eu.getBaseCost();
        }
        return cost;
    }

    public String factionCode() {
        return "";
    }

    @Override
    public EquippedShipBase setFlagship(Flagship v) {
        if (v != null) {
            throw new RuntimeException("Can't add a flagship to the sideboard.");
        }
        return super.setFlagship(v);
    }

    @Override
    public boolean isResourceSideboard() {
        return true;
    }

    @Override
    public EquippedShipBase setShip(Ship v) {
        if (v != null) {
            throw new RuntimeException("You can't add a ship to the sideboard.");
        }
        return super.setShip(v);
    }

}
