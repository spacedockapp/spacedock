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

        if (inShip.getExternalId().equals("enterprise_nx_01_71526")) {
            Upgrade hullPlating = Universe.getUniverse().getUpgrade("enhanced_hull_plating_71526");
            if (containsUpgrade(Universe.getUniverse().getUpgrade("enhanced_hull_plating_71526")) == null) {
                addUpgrade(hullPlating, null, false);
            }
        }
    }

    public boolean isResourceSideboard() {
        return (mShip == null);
    }

    public boolean isShuttle() { return mShip.isShuttle(); }

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

        if (getCaptain().getSpecial().equals("Ship2LessAndUpgrades1Less")) {
            cost -= 2;
            if (cost < 0) {
                cost = 0;
            }
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

        for (EquippedUpgrade eu : getUpgrades()) {
            Upgrade upgrade = eu.getUpgrade();
            if (upgrade != null) {
                v += upgrade.additionalTechSlots();
                if (upgrade.getExternalId().equals("enhanced_hull_plating_71526") && getExternalId().equals("enterprise_nx_01_71526")) {
                    v += 1;
                }
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
        for (EquippedUpgrade eu : getUpgrades()) {
            Upgrade upgrade = eu.getUpgrade();
            if (upgrade != null) {
                v += upgrade.additionalBorgSlots();
            }
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
        if (getCaptain() != null && getCaptain().getExternalId().equals("gareb_71536")) {
            v ++;
        }
        return v;
    }

    public int getAdmiralLimit() {
        int v = 0;
        v = getCaptainLimit();
        if (v > 1) {
            v = 1;
        }
        return v;
    }

    public int getOfficerLimit() {
        ArrayList<EquippedUpgrade> crewUpgrades = allUpgradesOfType(Constants.CREW_TYPE);
        int max = 2 * crewUpgrades.size();
        if (max > 4) {
            max = 4;
        }
        return max;
    }

    public int getTalent() {
        int v = 0;
        for (EquippedUpgrade eu : getUpgrades()) {
            Upgrade upgrade = eu.getUpgrade();
            if (upgrade != null) {
                v += upgrade.additionalTalentSlots();
            }
        }
        Flagship flagship = getFlagship();
        if (flagship != null) {
            v += flagship.getTalent();
        }
        if (getCaptain() != null && getCaptain().getExternalId().equals("brunt_72013")){
            v += 1;
        }
        if (getCaptain() != null && getCaptain().getExternalId().equals("lovok_72221a")){
            v += 1;
        }
        if (getCaptain() != null && getCaptain().getExternalId().equals("telek_r_mor_72016")){
            v += 1;
        }
        if (getCaptain() != null && getCaptain().isKazon() && getShip().isKazon()) {
            v += 1;
        }
        if (getCaptain() != null && getCaptain().getSpecial().equals("TwoBajoranTalents")) {
            v += 2;
        }
        if (getCaptain() != null && getCaptain().getSpecial().equals("OneRomulanTalentDiscIfFleetHasRomulan")) {
            if (mSquad != null) {
                ArrayList<EquippedShip> ships = mSquad.getEquippedShips();
                boolean rom = false;
                for (EquippedShip ship : ships) {
                    if (ship != this) {
                        if (ship.getShip().isRomulan()) {
                            rom = true;
                        }
                    }
                }
                if (rom) {
                    v += 1;
                }
            }
        }
        if (getCaptain() != null && getCaptain().getExternalId().equals("kurn_71999p")) {
            v += 1;
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
        for (EquippedUpgrade eu : getUpgrades()) {
            Upgrade upgrade = eu.getUpgrade();
            if (upgrade != null) {
                v += upgrade.additionalCrewSlots();
            }
        }
        if (getCaptain() != null && getCaptain().getSpecial().equals("RemanBodyguardsLess2")) {
            if (v == 0) {
                v++;
            } else {
                if (containsUpgradeWithName("Reman Bodyguards") != null) {
                    v++;
                }
            }
        }
        return v;
    }

    public int getSquadron() {
        int v = 0;
        Ship ship = getShip();
        if (ship != null) {
            v = ship.getSquadron();
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
                } else if (null != containsUpgrade(Universe.getUniverse().getUpgrade("romulan_hijackers_71802"))) {
                    Upgrade zcc = Captain.zeroCostCaptain("Romulan");
                } else {
                    Upgrade zcc = Captain.zeroCostCaptainForShip(getShip());
                    addUpgrade(zcc, null, false);
                }
            }
            int current = equipped("Captain");
            if (current > getCaptainLimit()) {
                removeOverLimit("Captain",current,getCaptainLimit());
            } else {
                for (int i=current; i < getCaptainLimit(); i++) {
                    Upgrade zcc = Captain.zeroCostCaptainForShip(getShip());
                    addUpgrade(zcc, null, false);
                }
            }
            establishPlaceholdersForType("Admiral", getAdmiralLimit());
        }
        establishPlaceholdersForType("Talent", getTalent());
        establishPlaceholdersForType("Crew", getCrew());
        establishPlaceholdersForType("Weapon", getWeapon());
        establishPlaceholdersForType("Tech", getTech());
        establishPlaceholdersForType("Borg", getBorg());
        establishPlaceholdersForType("Squadron", getSquadron());
        establishPlaceholdersForType("Officer", getOfficerLimit());
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

    public void removeIllegalUpgrades() {
        ArrayList<EquippedUpgrade> onesToRemove = new ArrayList<EquippedUpgrade>();

        EquippedUpgrade captain = getEquippedCaptain();
        int totalTE = 0;
        if (captain != null) {
            Explanation explanation = mSquad.canAddCaptain(getCaptain(),this);
            if (!explanation.canAdd) {
                String captainId = captain.getExternalId();
                if (getShip().getShipClass().equals("Romulan Drone Ship")) {
                    Captain gareb = Universe.getUniverse().getCaptain("gareb_71536");
                    Explanation explanation1 = mSquad.canAddCaptain(gareb, this);
                    if (explanation1.canAdd) {
                        removeUpgrade(captain);
                        addUpgrade((Upgrade) gareb);
                        Explanation explanation2 = tryEquipUpgrade(mSquad, SLOT_TYPE_CAPTAIN, 1, captainId);
                    } else {
                        onesToRemove.add(captain);
                    }
                } else {
                    onesToRemove.add(captain);
                }
            }
            for(EquippedUpgrade eu : mUpgrades) {
                if (!captain.getExternalId().equals("khan_singh_72317p") && !eu.isPlaceholder()) {
                    if (eu.getSpecialTag() != null && eu.getSpecialTag().equals("KhanDiscounted")) {
                        onesToRemove.add(eu);
                    }
                }
                if (eu.getUpgrade().getExternalId().equals("triphasic_emitter_71536")) {
                    totalTE++;
                }
            }
        }
        for (EquippedUpgrade eu : getSortedUpgrades()) {
            Upgrade upgrade = eu.getUpgrade();
            if (upgrade != null) {
                Explanation explanation = canAddUpgrade(upgrade, false);
                if (!explanation.canAdd) {
                    onesToRemove.add(eu);
                }
                if (eu.getSpecialTag() != null && eu.getSpecialTag().equals("HiddenWeaponTE")) {
                    if (totalTE > 0) {
                        totalTE--;
                    } else {
                        onesToRemove.add(eu);
                    }
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

    public String getAdditionalShipFaction() {
        Ship ship = getShip();
        if (ship == null) {
            return "Federation";
        }
        return ship.getAdditionalFaction();
    }

    public Explanation canAddUpgrade(Upgrade upgrade, boolean addingNew) {
        String msg = String.format("Can't add %s to %s",
                upgrade.getPlainDescription(), getPlainDescription());
        if (isFighterSquadron()) {
            return new Explanation(msg,
                    "Fighter Squadrons cannot accept upgrades.");
        }
        if (upgrade.isFleetCaptain()) {
            return canAddFleetCaptain((FleetCaptain) upgrade);
        }
        if (upgrade.isOfficer()) {
            return canAddOfficer((Officer) upgrade);
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
        if ("OnlyShip_I.S.S._Enterprise".equals(upgradeSpecial)) {
            if (!ship.isISSEnterprise()) {
                return new Explanation(msg,
                        "This upgrade can only be added to the I.S.S Enterprise.");
            }
        }
        if (upgradeSpecial.equals("OnlyKlingonBirdOfPrey")) {
            if (!ship.isKlingonBoP()) {
                return new Explanation(msg,
                        "This upgrade can only be added to a Klingon Bird Of Prey.");
            }
        }
        if (upgradeSpecial.equals("OnlyRemanWarbird")) {
            if (!ship.isRemanWarbird()) {
                return new Explanation(msg,
                        "This upgrade can only be added to a Reman Warbird.");
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
        if ("dual_phaser_banks_72002p".equals(upgrade.getExternalId())) {
            if (!ship.isFederation()) {
                return new Explanation(msg, "This upgrade can only be added to Federation ships.");
            }
        }
        if ("OnlyRomulanShip".equals(upgradeSpecial)){
            if (!ship.isRomulan()) {
                return new Explanation(msg, "This upgrade can only be added to Romulan ships.");
            }
        }
        if ("OnlyDominionShip".equals(upgradeSpecial)) {
            if (!ship.isDominion()) {
                return new Explanation(msg, "This upgrade can only be added to Dominion ships.");
            }
        }
        if ("OnlyBattleshipOrCruiser".equals(upgradeSpecial)) {
            if (!ship.isBattleshipOrCruiser()) {
                return new Explanation(msg, "This upgrade can only be purchased for a Jem'Hadar Battleship or Battle Cruiser.");
            }
        }
        if ("limited_max_weapon_3AndPlus5NonFed".equals(upgradeSpecial)) {
            if (ship.getAttack() > 3) {
                return new Explanation(msg, "You may only deploy this upgrade to a ship with a Primary Weapon Value of 3 or less.");
            }
        }
        if ("combat_vessel_variant_71508".equals(upgradeSpecial)
                || "only_suurok_class_limited_weapon_hull_plus_1".equals(upgradeSpecial)) {
            if (!ship.isSuurok()) {
                return new Explanation(msg, "This upgrade can only be purchased for a Suurok Class Ship.");
            }
            if (addingNew && null != containsUpgrade(upgrade)) {
                return new Explanation(msg, "This upgrade can only be added once per ship.");
            }
        }
        if (upgradeSpecial.startsWith("OnlyShipClass_")) {
            if (upgradeSpecial.startsWith("OnlyShipClass_CONTAINS_")) {
                String reqMatch = upgradeSpecial.substring(23);

                if (!ship.getShipClass().contains(reqMatch)) {
                    return new Explanation(msg, "This upgrade can only be purchased for a " + reqMatch.replace("_", " ") + " Ship.");
                }
            } else {
                String reqClass = upgradeSpecial.substring(14);

                if (!reqClass.equals(ship.getShipClass().replace(" ", "_"))) {
                    return new Explanation(msg, "This upgrade can only be purchased for a " + reqClass.replace("_", " ") + " Class Ship.");
                }
            }
        }
        if (upgradeSpecial.startsWith("OPSOnlyShipClass_")) {
            if (upgradeSpecial.startsWith("OPSOnlyShipClass_CONTAINS_")) {
                String reqMatch = upgradeSpecial.substring(26);

                if (!ship.getShipClass().contains(reqMatch)) {
                    return new Explanation(msg, "This upgrade can only be purchased for a " + reqMatch.replace("_", " ") + " Ship.");
                }
            } else {
                String reqClass = upgradeSpecial.substring(17);

                if (!reqClass.equals(ship.getShipClass().replace(" ", "_"))) {
                    return new Explanation(msg, "This upgrade can only be purchased for a " + reqClass.replace("_", " ") + " Class Ship.");
                }
            }
        }
        if (upgradeSpecial.equals("OnlyKazonShip")) {
            if (!ship.isKazon()) {
                return new Explanation(msg,
                        "This upgrade can only be added to Kazon ships.");
            }
        }
        if ("OnlyBajoran".equals(upgradeSpecial)) {
            if (!ship.isBajoran()) {
                return new Explanation(msg, "This upgrade can only be added to a Bajoran ship.");
            }
        }
        if ("OnlyBajoranShip".equals(upgradeSpecial)) {
            if (!ship.isBajoran() || !getCaptain().isBajoran()) {
                return new Explanation(msg, "This upgrade can only be added to a Bajoran Captain assigned to a Bajoran ship.");
            }
        }
        if ("OnlyBajoranFederation".equals(upgradeSpecial)) {
            if (!ship.isBajoran() && !ship.isFederation()) {
                return new Explanation(msg, "This upgrade can only be added to a Bajoran or Federation ship.");
            }
        }
        if ("OnlyKlingon".equals(upgradeSpecial)) {
            if (!ship.isKlingon()) {
                return new Explanation(msg, "This upgrade can only be added to a Klingon ship.");
            }
        }
        if ("NoMoreThanOnePerShip".equals(upgradeSpecial) || "OnlyBorgShipAndNoMoreThanOnePerShip".equals(upgradeSpecial) || upgradeSpecial.endsWith("NoMoreThanOnePerShip") || upgradeSpecial.startsWith("NoMoreThanOnePerShip") || upgradeSpecial.startsWith("OPSOnlyShipClass")  || upgradeSpecial.startsWith("OPSPlus")) {
            if (addingNew && null != containsUpgrade(upgrade)) {
                return new Explanation(msg, "This upgrade can only be added once per ship.");
            } else if (addingNew && (upgrade.getExternalId().equals("unremarkable_species_72018")
                    || upgrade.getExternalId().equals("unremarkable_species_c_72018")
                    || upgrade.getExternalId().equals("unremarkable_species_t_72018")
                    || upgrade.getExternalId().equals("unremarkable_species_w_72018"))) {
                if (null != containsUpgrade(Universe.getUniverse().getUpgrade("unremarkable_species_72018"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("unremarkable_species_c_72018"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("unremarkable_species_t_72018"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("unremarkable_species_w_72018"))) {
                    return new Explanation(msg, "This upgrade can only be added once per ship.");
                }
            } else if (addingNew && (upgrade.getExternalId().equals("maintenance_crew_c_72022")
                    || upgrade.getExternalId().equals("maintenance_crew_t_72022")
                    || upgrade.getExternalId().equals("maintenance_crew_w_72022"))) {
                if (null != containsUpgrade(Universe.getUniverse().getUpgrade("maintenance_crew_c_72022"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("maintenance_crew_t_72022"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("maintenance_crew_w_72022"))) {
                    return new Explanation(msg, "This upgrade can only be added once per ship.");
                }
            } else if (addingNew && (upgrade.getExternalId().equals("auxiliary_control_room_t_72316p")
                    || upgrade.getExternalId().equals("auxiliary_control_room_w_72316p"))) {
                if (null != containsUpgrade(Universe.getUniverse().getUpgrade("auxiliary_control_room_t_72316p"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("auxiliary_control_room_w_72316p"))) {
                    return new Explanation(msg, "This upgrade can only be added once per ship.");
                }
            } else if (addingNew && (upgrade.getExternalId().equals("automated_distress_beacon_c_72316p")
                    || upgrade.getExternalId().equals("automated_distress_beacon_t_72316p")
                    || upgrade.getExternalId().equals("automated_distress_beacon_w_72316p"))) {
                if (null != containsUpgrade(Universe.getUniverse().getUpgrade("automated_distress_beacon_c_72316p"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("automated_distress_beacon_t_72316p"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("automated_distress_beacon_w_72316p"))) {
                    return new Explanation(msg, "This upgrade can only be added once per ship.");
                }
            } else if (addingNew && (upgrade.getExternalId().equals("computer_core_c_72336")
                    || upgrade.getExternalId().equals("computer_core_w_72336"))) {
                if (null != containsUpgrade(Universe.getUniverse().getUpgrade("computer_core_c_72336"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("computer_core_w_72336"))) {
                    return new Explanation(msg, "This upgrade can only be added once per ship.");
                }
            } else if (addingNew && (upgrade.getExternalId().equals("delta_shift_c_72320p")
                    || upgrade.getExternalId().equals("delta_shift_t_72320p")
                    || upgrade.getExternalId().equals("delta_shift_w_72320p")
                    || upgrade.getExternalId().equals("delta_shift_e_72320p"))) {
                if (null != containsUpgrade(Universe.getUniverse().getUpgrade("delta_shift_c_72320p"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("delta_shift_t_72320p"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("delta_shift_w_72320p"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("delta_shift_e_72320p"))) {
                    return new Explanation(msg, "This upgrade can only be added once per ship.");
                }
            }
        }
        if ("NoMoreThanOnePerShipBajoran".equals(upgradeSpecial)) {
            if (addingNew && null != containsUpgrade(upgrade)) {
                return new Explanation(msg, "This upgrade can only be added once per ship.");
            }
            if (!ship.isBajoran()) {
                return new Explanation(msg, "This upgrade can only be added to a Bajoran ship.");
            }
        }
        if ("NoMoreThanOnePerShipBajoranInterceptor".equals(upgradeSpecial)) {
            if (addingNew && null != containsUpgrade(upgrade)) {
                return new Explanation(msg, "This upgrade can only be added once per ship.");
            }
            if (!ship.getShipClass().equals("Bajoran Interceptor")) {
                return new Explanation(msg, "This upgrade can only be added to a Bajoran Interceptor.");
            }
        }
        if ("NoMoreThanOnePerShipBajoranScout".equals(upgradeSpecial)) {
            if (addingNew && null != containsUpgrade(upgrade)) {
                return new Explanation(msg, "This upgrade can only be added once per ship.");
            }
            if (!ship.getShipClass().equals("Bajoran Scout Ship")) {
                return new Explanation(msg, "This upgrade can only be added to a Bajoran Scout Ship.");
            }
        }
        if ("NoMoreThanOnePerShipKlingon".equals(upgradeSpecial)) {
            if (addingNew && null != containsUpgrade(upgrade)) {
                return new Explanation(msg, "This upgrade can only be added once per ship.");
            }
            if (!ship.isKlingon()) {
                return new Explanation(msg, "This upgrade can only be added to a Klingon ship.");
            }
        }
        if ("NoMoreThanOnePerShipFederation".equals(upgradeSpecial)) {
            if (addingNew && null != containsUpgrade(upgrade)) {
                return new Explanation(msg, "This upgrade can only be added once per ship.");
            } else if (addingNew && (upgrade.getExternalId().equals("systems_upgrade_71998p")
                || upgrade.getExternalId().equals("systems_upgrade_c_71998p")
                || upgrade.getExternalId().equals("systems_upgrade_w_71998p"))) {
                if (null != containsUpgrade(Universe.getUniverse().getUpgrade("systems_upgrade_71998p"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("systems_upgrade_c_71998p"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("systems_upgrade_w_71998p"))) {
                    return new Explanation(msg, "This upgrade can only be added once per ship.");
                }
            }

            if (!ship.isFederation()) {
                return new Explanation(msg, "This upgrade can only be added to a Federation ship.");
            }
        }
        if ("NoMoreThanOnePerShipFerengi".equals(upgradeSpecial)) {
            if (addingNew && null != containsUpgrade(upgrade)) {
                return new Explanation(msg, "This upgrade can only be added once per ship.");
            } else if (addingNew && (upgrade.getExternalId().equals("cargo_hold_20_72013")
                    || upgrade.getExternalId().equals("cargo_hold_11_72013")
                    || upgrade.getExternalId().equals("cargo_hold_02_72013"))) {
                if (null != containsUpgrade(Universe.getUniverse().getUpgrade("cargo_hold_20_72013"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("cargo_hold_11_72013"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("cargo_hold_02_72013"))) {
                    return new Explanation(msg, "This upgrade can only be added once per ship.");
                }
            }
            if (!ship.isFerengi()) {
                return new Explanation(msg, "This upgrade can only be added to a Ferengi ship.");
            }
        }
        if ("OnlyBorgShipAndNoMoreThanOnePerShip".equals(upgradeSpecial)) {
            if (!ship.isBorg()) {
                return new Explanation(msg, "This upgrade can only be added to a borg ship.");
            }
        }
        if ("ony_federation_ship_limited".equals(upgradeSpecial)) {
            if (addingNew && null != containsUpgrade(upgrade)) {
                return new Explanation(msg, "This upgrade can only be added once per ship.");
            }
            if (!ship.isFederation()) {
                return new Explanation(msg, "This upgrade can only be added to a federation ship.");
            }
        }
        if ("ony_federation_ship_limited3".equals(upgradeSpecial)) {
            if (addingNew && null != containsUpgrade(upgrade)) {
                return new Explanation(msg, "This upgrade can only be added once per ship.");
            }
            if (!ship.isFederation()) {
                return new Explanation(msg, "This upgrade can only be added to a federation ship.");
            }
            if (3 < ship.getHull()) {
                return new Explanation(msg, "This upgrade can only be added to ship with a hull of 3 or less.");
            }
        }
        if ("ony_mu_ship_limited".equals(upgradeSpecial)) {
            if (addingNew && null != containsUpgrade(upgrade)) {
                return new Explanation(msg, "This upgrade can only be added once per ship.");
            }
            if (!ship.isMirrorUniverse()) {
                return new Explanation(msg, "This upgrade can only be added to a Mirror Universe ship.");
            }
            if (4 < ship.getHull()) {
                return new Explanation(msg, "This upgrade can only be added to ship with a hull of 4 or less.");
            }
        }
        if ("limited_max_weapon_3".equals(upgradeSpecial)) {
            if (addingNew && null != containsUpgrade(upgrade)) {
                return new Explanation(msg, "This upgrade can only be added once per ship.");
            }
            if (3 < ship.getAttack()) {
                return new Explanation(msg, "This upgrade can only be added to ship with a attack of 3 or less.");
            }
        }
        if ("OnlyFedShipHV4CostPWVP1".equals(upgradeSpecial)) {
            if (!ship.isFederation()) {
                return new Explanation(msg, "This upgrade can only be added to a federation ship.");
            }
            if (4 > ship.getHull()) {
                return new Explanation(msg, "This upgrade can only be added to ship with a hull of 4 or greater.");
            }
        }
        if ("OnlyFedShipHV4CostPWV".equals(upgradeSpecial)) {
            if (!ship.isFederation()) {
                return new Explanation(msg, "This upgrade can only be added to a federation ship.");
            }
            if (4 > ship.getHull()) {
                return new Explanation(msg, "This upgrade can only be added to ship with a hull of 4 or greater.");
            }
        }
        if ("OnlyDominionHV4".equals(upgradeSpecial)) {
            if (!ship.isDominion()) {
                return new Explanation(msg, "This upgrade can only be added to a federation ship.");
            }
            if (4 > ship.getHull()) {
                return new Explanation(msg, "This upgrade can only be added to ship with a hull of 4 or greater.");
            }
        }
        if ("OnlyDderidexAndNoMoreThanOnePerShip".equals(upgradeSpecial)) {
            if (addingNew && null != containsUpgrade(upgrade)) {
                return new Explanation(msg, "This upgrade can only be added once per ship.");
            }

            if (!ship.getShipClass().equals("D'deridex Class")) {
                return new Explanation(msg, "This upgrade can only be added to a D'deridex class ship.");
            }
        }
        if ("OnlyIntrepidAndNoMoreThanOnePerShip".equals(upgradeSpecial)) {
            if (!ship.getShipClass().equals("Intrepid Class")) {
                return new Explanation(msg, "This upgrade can only be added to an Intrepid class ship.");
            }
        }
        if ("Hull4NoRearPlus5NonFed".equals(upgradeSpecial)) {
            if (ship.getShipClassDetails().hasRearFiringArc()) {
                return new Explanation(msg, "This upgrade can only be added to a ship without a rear firing arc.");
            }
            if (ship.getHull() < 4) {
                return new Explanation(msg, "This upgrade can only be added to a ship with a hull of 4 or greater.");
            }
        }
        if ("PlusFiveNotKlingonAndMustHaveComeAbout".equals(upgradeSpecial)) {
            if (!ship.getShipClassDetails().getMovesSummary().contains("come about")) {
                return new Explanation(msg, "This upgrade can only be added to a ship with a come about maneuver.");
            }
        }
        if ("MustHaveBS".equals(upgradeSpecial)) {
            if (ship.getBattleStations() == 0) {
                return new Explanation(msg, "This upgrade can only be added to a ship with a battle stations ship action.");
            }
        }
        Captain captain = getCaptain();
        if (null != captain) {
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
                if (upgradeSpecial.equals("OnlyKlingonCaptainShip")) {
                    if (!captain.isKlingon() || !ship.isKlingon()) {
                        return new Explanation(msg,
                                "This upgrade can only be added to a Klingon Captain on a Klingon Ship.");
                    }
                }
                if (upgradeSpecial.equals("OnlyKlingonORRomulanCaptainShip")) {
                    if (!captain.isKlingon() && !captain.isRomulan()) {
                        return new Explanation(msg,
                                "This upgrade can only be added to a Klingon or Romulan Captain on a Klingon or Romulan Ship.");
                    }
                    if (!ship.isKlingon() && !ship.isRomulan()) {
                        return new Explanation(msg,
                                "This upgrade can only be added to a Klingon or Romulan Captain on a Klingon or Romulan Ship.");
                    }
                }

                if (upgradeSpecial.equals("OnlySpecies8472Ship") || upgradeSpecial.endsWith("OnlySpecies8472Ship")) {
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
                if ("shinzon_romulan_talents_71533".equals(upgrade.getExternalId()) && !"shinzon_71533".equals(captain.getExternalId())) {
                    return new Explanation(msg,
                            "This talent may only be equiped by Shinzon.");
                }
                if (captain.getExternalId().equals("k_temoc_72009") && upgrade.isTalent()) {
                    if (!upgrade.isKlingon()) {
                        return new Explanation(msg,
                                "K'Temoc may only field Klingon [TALENT] upgrades.");
                    }
                }
                if (upgradeSpecial.equals("OnlyKazonCaptainShip")) {
                    if (!captain.isKazon() || !ship.isKazon()) {
                        return new Explanation(msg,
                                "This upgrade can only be added to a Kazon Captain on a Kazon Ship.");
                    }
                }
                if (upgradeSpecial.equals("OnlyVulcanCaptainVulcanShip")) {
                    if (!captain.isVulcan() || !ship.isVulcan()) {
                        return new Explanation(msg,
                                "This upgrade can only be added to a Vulcan Captain on a Vulcan Ship.");
                    }
                }
            }

            if (upgradeSpecial.equals("OnlyTholianCaptain")) {
                if (!captain.isTholian()) {
                    return new Explanation(msg,
                            "This upgrade can only be added to a Tholian Captain.");
                }
            }

            if ("OnlyNonBorgShipAndNonBorgCaptain".equals(upgradeSpecial)) {
                if (captain.isBorgFaction() || ship.isBorg()) {
                    return new Explanation(msg,
                            "This upgrade cannot be added to a Borg captain or Borg Ship.");
                }
            }

            if ("OnlyRomulanCaptainShip".equals(upgradeSpecial)){
                if (!captain.isRomulan() || !ship.isRomulan()){
                    return new Explanation(msg,
                            "This upgrade can only be added to a Romulan captain on a Romulan Ship.");
                }
            }

            if ("OnlyRomulanCaptain".equals(upgradeSpecial)){
                if (!captain.isRomulan()){
                    return new Explanation(msg,
                            "This upgrade can only be added to a Romulan captain.");
                }
            }

            if ("OnlyFederationCaptainShip".equals(upgradeSpecial)) {
                if (!captain.isFederation() || !ship.isFederation()) {
                    return new Explanation(msg,
                            "This upgrade can only be added to a Federation captain on a Federation Ship.");
                }
            }

            if (upgradeSpecial.equals("OnlyXindi") || upgradeSpecial.endsWith("OnlyXindi") || upgradeSpecial.startsWith("OnlyXindi")) {
                if (!ship.isXindi()) {
                    return new Explanation(msg,
                            "This upgrade can only be added to Xindi ships.");
                }
            }

            if (upgradeSpecial.equals("OnlyXindiCaptainShip")) {
                if (!ship.isXindi() || !captain.isXindi()) {
                    return new Explanation(msg,
                            "This upgrade can only be added to a Xindi ship with a Xindi Captain.");
                }
            }
            if (upgradeSpecial.equals("OnlyLBCaptain")) {
                if (!captain.getTitle().equals("Lursa") && !captain.getTitle().equals("B'Etor")) {
                    if (upgrade.getTitle().equals("Lursa")) {
                        return new Explanation(msg,
                                "B'Etor must be the captain when assigning Lursa as Crew.");
                    } else {
                        return new Explanation(msg,
                                "Lursa must be the captain when assigning B'Etor as Crew.");
                    }
                }
            }
            if (upgrade.isTalent() && !upgrade.isPlaceholder()) {
                if (getCaptain() != null && getCaptain().getExternalId().equals("brunt_72013")) {
                    int limit = getTalent();
                    if (limit == 1) {
                        if (!upgrade.getTitle().equals("Grand Nagus")) {
                            return new Explanation(msg,
                                    "Brunt may only field the Grand Nagus [TALENT] Upgrade");
                        }
                    } else {
                        for (EquippedUpgrade eu : mUpgrades) {
                            if (!eu.isPlaceholder() && eu.getUpgrade().isTalent()) {
                                limit--;
                            }
                        }
                        if (limit <= 1 && containsUpgradeWithName("Grand Nagus") == null) {
                            if (addingNew && !upgrade.getTitle().equals("Grand Nagus")) {
                                return new Explanation(msg,
                                        "Brunt may only field the Grand Nagus [TALENT] Upgrade");
                            }
                        }
                    }
                }
                if (getCaptain() != null && getCaptain().getExternalId().equals("lovok_72221a")) {
                    int limit = getTalent();
                    if (limit == 1) {
                        if (!upgrade.getTitle().equals("Tal Shiar")) {
                            return new Explanation(msg,
                                    "Lovok may only field the Tal Shiar [TALENT] Upgrade");
                        }
                    } else {
                        for (EquippedUpgrade eu : mUpgrades) {
                            if (!eu.isPlaceholder() && eu.getUpgrade().isTalent()) {
                                limit--;
                            }
                        }
                        if (limit <= 1 && containsUpgradeWithName("Tal Shiar") == null) {
                            if (addingNew && !upgrade.getTitle().equals("Tal Shiar")) {
                                return new Explanation(msg,
                                        "Lovok may only field the Tal Shiar [TALENT] Upgrade");
                            }
                        }
                    }
                }
                if (getCaptain() != null && getCaptain().getExternalId().equals("telek_r_mor_72016")) {
                    int limit = getTalent();
                    if (limit == 1) {
                        if (!upgrade.getTitle().equals("Secret Research")) {
                            return new Explanation(msg,
                                    "Telek R'Mor may only field the Secret Research [TALENT] Upgrade");
                        }
                    } else {
                        for (EquippedUpgrade eu : mUpgrades) {
                            if (!eu.isPlaceholder() && eu.getUpgrade().isTalent()) {
                                limit--;
                            }
                        }
                        if (limit <= 1 && containsUpgradeWithName("Secret Research") == null) {
                            if (addingNew && !upgrade.getTitle().equals("Secret Research")) {
                                return new Explanation(msg,
                                        "Telek R'Mor may only field the Secret Research [TALENT] Upgrade");
                            }
                        }
                    }
                }
                if (getCaptain() != null && getCaptain().getSpecial().equals("OnlyKlingonTalent")) {
                    int limit = getTalent();
                    if (limit == 1) {
                        if (!upgrade.isKlingon()) {
                            return new Explanation(msg,
                                    "This Captain may only field 1 Klingon [TALENT] Upgrade");
                        }
                    } else {
                        boolean hasKT = false;
                        for (EquippedUpgrade eu : mUpgrades) {
                            if (!eu.isPlaceholder() && eu.getUpgrade().isTalent()) {
                                limit--;
                                if (eu.getUpgrade().isKlingon()) {
                                    hasKT = true;
                                }
                            }
                        }
                        if (limit <= 1 && !hasKT) {
                            if (addingNew && !upgrade.isKlingon()) {
                                return new Explanation(msg,
                                        "This Captain may only field 1 Klingon [TALENT] Upgrade");
                            }
                        }
                    }
                }
                if (getCaptain() != null && getCaptain().getSpecial().equals("OneRomulanTalentDiscIfFleetHasRomulan")) {
                    int limit = getTalent();
                    if (limit == 1) {
                        if (!upgrade.isRomulan()) {
                            return new Explanation(msg,
                                    getCaptain().getTitle() + " may only field a Romulan [TALENT] Upgrade");
                        }
                    } else {
                        for (EquippedUpgrade eu : mUpgrades) {
                            if (!eu.isPlaceholder() && eu.getUpgrade().isTalent()) {
                                limit--;
                            }
                        }
                        if (limit <= 1 && !upgrade.isRomulan()) {
                            if (addingNew && !upgrade.isRomulan()) {
                                return new Explanation(msg,
                                        getCaptain().getTitle() + " may only field a Romulan [TALENT] Upgrade");
                            }
                        }
                    }
                }
                if (getCaptain() != null && getCaptain().getSpecial().equals("TwoBajoranTalents")) {
                    int limit = getTalent();
                    if (limit == 2) {
                        if (!upgrade.isBajoran()) {
                            return new Explanation(msg,
                                    getCaptain().getTitle() + " may only field the Bajoran [TALENT] Upgrades");
                        }
                    } else {
                        for (EquippedUpgrade eu : mUpgrades) {
                            if (!eu.isPlaceholder() && eu.getUpgrade().isTalent()) {
                                limit--;
                            }
                        }
                        if (limit <= 2) {
                            if (addingNew && !upgrade.isBajoran()) {
                                return new Explanation(msg,
                                        getCaptain().getTitle() + " may only field the Bajoran [TALENT] Upgrades");
                            }
                        }
                    }
                }
                if (getCaptain() != null && getCaptain().getExternalId().equals("kurn_71999p")) {
                    int limit = getTalent();
                    if (limit == 1) {
                        if (!upgrade.getTitle().equals("Mauk-to'Vor")) {
                            return new Explanation(msg,
                                    "Kurn may only field the Mauk-to'Vor [TALENT] Upgrade");
                        }
                    } else {
                        for (EquippedUpgrade eu : mUpgrades) {
                            if (!eu.isPlaceholder() && eu.getUpgrade().isTalent()) {
                                limit--;
                            }
                        }
                        if (limit <= 1 && containsUpgradeWithName("Mauk-to'Vor") == null) {
                            if (addingNew && !upgrade.getTitle().equals("Mauk-to'Vor")) {
                                return new Explanation(msg,
                                        "Kurn may only field the Mauk-to'Vor [TALENT] Upgrade");
                            }
                        }
                    }
                }
                if (upgradeSpecial.equals("OnlyBorgQueen") && getCaptain() != null && !getCaptain().getTitle().equals("Borg Queen")) {
                    return new Explanation(msg,
                            "This upgrade may only be assinged to the Borg Queen");
                }
            }
        }

        if (!upgrade.isPlaceholder() && upgrade.isWeapon() && this.containsUpgradeWithSpecial("addoneweaponslotfortorpedoes") != null) {
            int limit = getWeapon() - 1;
            for (EquippedUpgrade eu : mUpgrades) {
                if (!eu.isPlaceholder() && eu.getUpgrade().isWeapon()) {
                    if (!eu.getTitle().startsWith("Photon Torpedoes"))
                        limit--;
                }
            }

            if (!upgrade.getTitle().startsWith("Photon Torpedoes")) {
                if (!addingNew) {
                    limit++;
                }
                if (limit < 1) {
                    return new Explanation(msg, "You may only equip a Photon Torpedoes upgrade in this slot.");
                }
            }
        }

        if ("Borg Scout Cube".equalsIgnoreCase(ship.getShipClass())
                && upgrade.isBorg() && upgrade.getCost() > 5) {
            return new Explanation(msg,
                    "Cannot equip a Borg upgrade with cost greater than 5 to this ship.");
        }

        if ("systems_upgrade_71998p".equals(upgrade.getExternalId())
                || "systems_upgrade_c_71998p".equals(upgrade.getExternalId())
                || "systems_upgrade_w_71998p".equals(upgrade.getExternalId())) {
            if (addingNew) {
                if (null != containsUpgrade(Universe.getUniverse().getUpgrade("systems_upgrade_71998p"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("systems_upgrade_c_71998p"))
                        || null != containsUpgrade(Universe.getUniverse().getUpgrade("systems_upgrade_w_71998p"))) {
                    return new Explanation(msg, "This upgrade can only be added once per ship.");
                }
            }
        }
        if (null != containsUpgrade(Universe.getUniverse().getUpgrade("romulan_hijackers_71802"))) {
            if (upgrade.isCrew()) {
                if (!upgrade.isRomulan()) {
                    return new Explanation(msg,"You may only deploy Romulan Crew Upgrades while this ship is equipped with the Romulan Hijackers Upgrade");
                }
            }
        }

        if (ship.isShuttle() && upgrade.isWeapon() && !upgrade.getExternalId().equals("3007")) {
            EquippedUpgrade tmpEu = new EquippedUpgrade();
            tmpEu.setUpgrade(upgrade);
            if (ship.getShipClass().equals("Delta Flyer Class Shuttlecraft")) {
                if (upgrade.calculateCostForShip(this,tmpEu) > 4) {
                    return new Explanation(msg, "You cannot deploy a [WEAPON] Upgrade with a cost greater than 4 to a Delta Flyer Class Shuttlecraft.");
                }
            } else {
                if (upgrade.calculateCostForShip(this, tmpEu) > 3) {
                    return new Explanation(msg, "You cannot deploy a [WEAPON] Upgrade with a cost greater than 3 to a shuttlecraft.");
                }
            }
        }

        if (upgrade.isTech() && null != containsUpgradeWithSpecial("Add3FedTech4Less")) {
            int tech = 0;
            for(EquippedUpgrade eu : mUpgrades) {
                if (eu.getUpgrade().isTech() && !eu.isPlaceholder()) {
                    if (eu.getSpecialTag() == null || !eu.getSpecialTag().startsWith("fed3_tech_")) {
                        tech++;
                    }
                }
            }
            EquippedUpgrade tmpEu = new EquippedUpgrade();
            tmpEu.setUpgrade(upgrade);
            if (!upgrade.isFederation() || upgrade.calculateCostForShip(this,tmpEu) > 4) {
                int artificialLimit = getTech() - tech - 3;
                if (!addingNew) {
                    artificialLimit ++;
                }
                if (artificialLimit <= 0) {
                    return new Explanation(msg,"You can only deploy Federation [TECH] Upgrades costing 4 or less to " + containsUpgradeWithSpecial("Add3FedTech4Less").getTitle() + ".");
                }
            }
        }

        if (upgradeSpecial.equals("BSVT") && this.getSquad().containsUniqueUpgradeWithName("Borg Support Vehicle Dock") == null) {
            return new Explanation(msg,"The Borg Support Vehicle Token may only be applied when a ship in your fleet is equipped with the Borg Support Vehicle Dock upgrade.");
        }
        if (upgradeSpecial.equals("BSVT") && this.getHull() > 7) {
            return new Explanation(msg,"The Borg Support Vehicle Token may only be applied when a ship with a Hull Value of 7 or less.");
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
        if (!captain.getUnique() && !captain.getMirrorUniverseUnique()) {
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

    public Explanation canAddOfficer(Officer officer) {
        ArrayList<EquippedUpgrade> crewUpgrades = allUpgradesOfType(Constants.CREW_TYPE);
        int crewCount = crewUpgrades.size();
        ArrayList<EquippedUpgrade> officerUpgrades = allUpgradesOfType(Constants.OFFICER_TYPE);
        int limit = getOfficerLimit();
        if (officerUpgrades.size() > limit) {
            String msg = String.format("Can't add %s to the selected squadron.", officer.getTitle());
            String info = null;
            if (crewCount > 0) {
                info = String.format("This ship has %d crew and can install no more than %d officer cards.", crewCount, limit);
            } else {
                info = "Officers must be installed with crew and this ship has no crew ";
            }
            return new Explanation(msg, info);
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

    public EquippedUpgrade containsUpgradeWithSpecial(String theName) {
        for (EquippedUpgrade eu : mUpgrades) {
            if (eu.getUpgrade().getSpecial().equals(theName)) {
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

    public void removeOfficers() {
        ArrayList <EquippedUpgrade> officers = allUpgradesOfType(Constants.OFFICER_TYPE);
        for (EquippedUpgrade eu : officers) {
            removeUpgrade(eu);
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
    public static final int SLOT_TYPE_SQUADRON = 9;
    public static final int SLOT_TYPE_OFFICER = 10;
    public static final int SLOT_TYPE_SHIP = 1000;

    public static Class[] CLASS_FOR_SLOT = new Class[]{
            Captain.class,
            Crew.class, Weapon.class, Tech.class, Borg.class, Talent.class,
            Flagship.class, Admiral.class, FleetCaptain.class, Squadron.class, Officer.class
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
        if (this.getExternalId().equals("enterprise_nx_01_71526") && !ship.getExternalId().equals("enterprise_nx_01_71526")) {
            EquippedUpgrade hullPlating = containsUpgrade(Universe.getUniverse().getUpgrade("enhanced_hull_plating_71526"));
            if (hullPlating != null) {
                removeUpgrade(hullPlating);
            }
        }
        setShip(ship);

        if (ship.getExternalId().equals("enterprise_nx_01_71526")) {
            Upgrade hullPlating = Universe.getUniverse().getUpgrade("enhanced_hull_plating_71526");
            addUpgrade(hullPlating, null, false);
        }

        // TODO: consider swapping zero cost captain for new faction?
        removeIllegalUpgrades();
        establishPlaceholders();

        return Explanation.SUCCESS;
    }

    public Explanation tryEquipFlagship(Squad squad, String externalId) {
        if (externalId == null) {
            squad.removeFlagship();
        } else {
            Flagship flagship = Universe.getUniverse().getFlagship(externalId);
            if (!flagship.compatibleWithFaction(shipFaction()) && !flagship.compatibleWithFaction(getAdditionalShipFaction())) {
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
        removeIllegalUpgrades();
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
        removeIllegalUpgrades();
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
            } else if (SLOT_TYPE_OFFICER == slotType) {
                Officer officer = Universe.getUniverse().getOfficer(externalId);
                Explanation explanation = squad.canAddUpgrade(officer, this);
                if (!explanation.canAdd) {
                    return explanation; // disallowed, abort!
                }
                explanation = canAddOfficer(officer);
                if (!explanation.canAdd) {
                    return explanation;
                }
                upgrade = officer;
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
            if (oldUpgrade != null && !oldUpgrade.isPlaceholder() && oldUpgrade.getExternalId().equals("gareb_71536")) {
                String result = String.format(
                        "Can't add %s to the selected squadron",
                        newEu.getTitle());
                return new Explanation(result, "This ship may only be assigned Gareb or a Romulan Drone Pilot as its Captain.");
            }
            oldUpgrade.setEquippedShip(null);
            mUpgrades.set(oldEuIndex, newEu);
        } else {
            mUpgrades.add(newEu);
        }

        if (getCaptain() != null && getCaptain().getExternalId().equals("gareb_71536") && newEu.isCaptain()) {
            if (!newEu.getExternalId().equals("gareb_71536")) {
                EquippedUpgrade gareb = getEquippedCaptain();

                int cost = newEu.getUpgrade().calculateCostForShip(this,newEu) - 3;
                if (cost < 0) {
                    cost = 0;
                }
                gareb.setOverridden(true);
                gareb.setOverriddenCost(cost);
                newEu.setOverridden(true);
                newEu.setOverriddenCost(0);
            }
        }

        if (upgrade.isTech() && null != containsUpgradeWithSpecial("Add3FedTech4Less")) {
            if (upgrade.isFederation() && upgrade.calculateCostForShip(this, newEu) <= 4) {
                int tech = 0;
                for (EquippedUpgrade eu : mUpgrades) {
                    if (eu.getUpgrade().isTech() && !eu.isPlaceholder() && eu.getSpecialTag() != null && eu.getSpecialTag().startsWith("fed3_tech_")) {
                        tech++;
                    }
                }
                if (tech < 3) {
                    newEu.setOverridden(true);
                    newEu.setOverriddenCost(0);
                    newEu.setSpecialTag("fed3_tech_" + Integer.toString(tech + 1));
                }
            }
        }

        if (upgrade.isWeapon() && !upgrade.getExternalId().equals("triphasic_emitter_71536") && null != containsUpgrade(Universe.getUniverse().getUpgrade("triphasic_emitter_71536"))) {
            if (upgrade.calculateCostForShip(this, newEu) <= 5) {
                int totalTE = 0;
                int totalHidden = 0;
                for (EquippedUpgrade eu : mUpgrades) {
                    if (eu.getUpgrade().isWeapon() && !eu.isPlaceholder() && eu.getSpecialTag() != null && eu.getSpecialTag().equals("HiddenWeaponTE")) {
                        totalHidden++;
                    } else if (eu.getUpgrade().getExternalId().equals("triphasic_emitter_71536")) {
                        totalTE++;
                    }
                }

                if (totalHidden < totalTE) {
                    newEu.setOverridden(true);
                    newEu.setOverriddenCost(0);
                    newEu.setSpecialTag("HiddenWeaponTE");
                }
            }
        }

        if (upgrade.isTech() && null != containsUpgradeWithSpecial("AddOneTechMinus1")) {
            if (upgrade.isRomulan()) {
                int tech = 0;
                for (EquippedUpgrade eu : mUpgrades) {
                    if (eu.getUpgrade().isTech() && !eu.isPlaceholder() && eu.getSpecialTag() != null && eu.getSpecialTag().startsWith("nijil_tech_")) {
                        tech++;
                    }
                }
                if (tech < 1) {
                    int cost = upgrade.calculateCostForShip(this, newEu);
                    if (cost > 1) {
                        newEu.setOverridden(true);
                        newEu.setOverriddenCost(cost - 1);
                    }
                    newEu.setSpecialTag("nijil_tech_" + Integer.toString(tech + 1));
                }
            }
        }

        if (upgrade.isTalent() && upgrade.isRomulan() && getCaptain() != null && getCaptain().getSpecial().equals("OneRomulanTalentDiscIfFleetHasRomulan")) {
            boolean discApplied = false;

            for (EquippedUpgrade eu : this.mUpgrades) {
                if (eu.getSpecialTag() != null && eu.getSpecialTag().equals("DiscRomTalent")) {
                    discApplied = true;
                }
            }
            if (!discApplied) {
                ArrayList<EquippedShip> ships = getSquad().getEquippedShips();
                boolean rom = false;
                for (EquippedShip ship : ships) {
                    if (ship != this) {
                        if (ship.getShip().isRomulan()) {
                            rom = true;
                        }
                    }
                }
                if (rom) {
                    int cost = newEu.getUpgrade().calculateCostForShip(this,newEu) - 1;
                    newEu.setOverridden(true);
                    newEu.setOverriddenCost(cost);
                    newEu.setSpecialTag("DiscRomTalent");
                }
            }
        }

        if (!newEu.isPlaceholder() && getCaptain() != null && getCaptain().getExternalId().equals("khan_singh_72317p")) {
            int cost = newEu.getUpgrade().calculateCostForShip(this,newEu);
            int count = 0;
            for(EquippedUpgrade eu : mUpgrades) {
                if (!eu.isPlaceholder()) {
                    if (eu.getSpecialTag() != null && eu.getSpecialTag().equals("KhanDiscounted")) {
                        count++;
                    }
                }
            }
            if (!newEu.isCaptain() && !newEu.getUpgrade().isAdmiral() && cost <= 6 && count < 3) {
                System.out.println("Discounted.");
                newEu.setSpecialTag("KhanDiscounted");
                newEu.setOverridden(true);
                newEu.setOverriddenCost(4);
            }
        }

        if (!newEu.isPlaceholder() && newEu.getUpgrade().isWeapon() && containsUpgradeWithSpecial("addoneweaponslot1xindi2less") != null) {
            int thisCost = newEu.getCost();
            int xindiDisc = 0;
            for(EquippedUpgrade eu : mUpgrades) {
                if (eu.getUpgrade().isTech() && !eu.isPlaceholder()) {
                    if (eu.getSpecialTag() == null || !eu.getSpecialTag().equals("xindixtraweapon")) {
                        xindiDisc++;
                    }
                }
            }
            if (xindiDisc == 0) {
                newEu.setSpecialTag("xindixtraweapon");
                if (thisCost <= 2) {
                    newEu.setOverriddenCost(0);
                } else {
                    newEu.setOverriddenCost(thisCost - 2);
                }
            }
        }

        newEu.setEquippedShip(this);
        // slot counts may have changed, refresh placeholders + prune slots to
        // new count
        removeIllegalUpgrades();
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

        if (isResourceSideboard()) {
            o.put(JSONLabels.JSON_LABEL_SIDEBOARD, true);
        } else {
            o.put(JSONLabels.JSON_LABEL_SHIP_ID, ship.getExternalId());
            o.put(JSONLabels.JSON_LABEL_SHIP_TITLE, ship.getTitle());
            Flagship flagship = getFlagship();
            if (flagship != null) {
                o.put(JSONLabels.JSON_LABEL_FLAGSHIP, flagship.getExternalId());
            }
        }

        final EquippedUpgrade equippedCaptain = getEquippedCaptain();
        if (null != equippedCaptain) {
            o.put(JSONLabels.JSON_LABEL_CAPTAIN, equippedCaptain.asJSON());
        }

        ArrayList<EquippedUpgrade> sortedUpgrades = getSortedUpgrades();
        JSONArray upgrades = new JSONArray();
        int index = 0;
        for (EquippedUpgrade upgrade : sortedUpgrades) {
            if (!upgrade.isPlaceholder()) {
                if (null == equippedCaptain || !upgrade.isEqualToUpgrade(equippedCaptain.getUpgrade())) {
                    upgrades.put(index++, upgrade.asJSON());
                }
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
            EquippedUpgrade eu = addUpgrade(captain, null, false);
            if (captainObject.optBoolean(JSONLabels.JSON_LABEL_COST_IS_OVERRIDDEN)) {
                eu.setOverridden(true);
                eu.setOverriddenCost(captainObject.optInt(JSONLabels.JSON_LABEL_OVERRIDDEN_COST));
            }
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
                    if (upgradeData.optString(JSONLabels.JSON_LABEL_SPECIALTAG) != null) {
                        eu.setSpecialTag(upgradeData.optString(JSONLabels.JSON_LABEL_SPECIALTAG));
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

    public String getExternalId() {
        return getShipExternalId();
    }
}
