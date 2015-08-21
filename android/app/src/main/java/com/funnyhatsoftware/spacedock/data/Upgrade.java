package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.TreeSet;

public class Upgrade extends UpgradeBase implements Factioned, Uniqueness {

    private static java.util.Set<String> sIneligibleTechUpgrades = new TreeSet<String>();

    static {
        String[] ineligibleTechUpgradeSpecials = {
                "OnlyVoyager",
                "OnlySpecies8472Ship",
                "PenaltyOnShipOtherThanDefiant",
                "PenaltyOnShipOtherThanKeldonClass",
                "OnlySpecies8472Ship",
                "CostPlusFiveExceptBajoranInterceptor",
                "PlusFiveForNonKazon",
                "OnlyForRomulanScienceVessel",
                "OnlyForRaptorClassShips",
                "OnlyJemHadarShips",
                "OnlyForRaptorClassShips",
                "OnlyFederationShip",
                "PlusFiveIfNotRaven"
        };
        sIneligibleTechUpgrades.addAll(Arrays.asList(ineligibleTechUpgradeSpecials));
    }

    static class UpgradeComparitor implements Comparator<Upgrade> {
        @Override
        public int compare(Upgrade o1, Upgrade o2) {
            int factionCompare = o1.getFaction().compareTo(o2.getFaction());
            if (factionCompare == 0) {
                int titleCompare = o1.getTitle().compareTo(o2.getTitle());
                if (titleCompare == 0) {
                    return DataUtils.compareInt(o2.getCost(), o1.getCost());
                }
                return titleCompare;
            }
            return factionCompare;
        }
    }

    public static Upgrade placeholder(String upType) {
        return Universe.getUniverse().findOrCreatePlaceholder(upType);
    }

    public String getTitle() {
        String title = super.getTitle();
        String externalId = getExternalId();
        if (externalId == null) {
            return title;
        }
        if (externalId.equals("quark_71786")) {
            title = String.format("%s (Tech)", title);
        } else if (externalId.equals("quark_weapon_71786")) {
            title = String.format("%s (Weapon)", title);
        } else if (externalId.equals("vulcan_high_command_2_0_71446")) {
            title = String.format("%s (2/0)", title);
        } else if (externalId.equals("vulcan_high_command_1_1_71446")) {
            title = String.format("%s (1/1)", title);
        } else if (externalId.equals("vulcan_high_command_0_2_71446")) {
            title = String.format("%s (0/2)", title);
        }
        return title;
    }

    public int limitForShip(EquippedShip targetShip) {
        if (isCaptain()) {
            return targetShip.getCaptainLimit();
        }
        if (isAdmiral()) {
            return targetShip.getAdmiralLimit();
        }

        if (isTalent()) {
            return targetShip.getTalent();
        }

        String special = mSpecial;
        if (special == null) {
            special = "";
        }

        if (special.equals("OnlyForRomulanScienceVessel")
                || special.equals("OnlyForRaptorClassShips")) {
            String shipClass = targetShip.getShip().getShipClass();
            if (!shipClass.equals(targetShipClass())) {
                return 0;
            }
        }

        if (isWeapon()) {
            return targetShip.getWeapon();
        }

        if (isCrew()) {
            return targetShip.getCrew();
        }

        if (isTech()) {
            return targetShip.getTech();
        }

        if (isBorg()) {
            return targetShip.getBorg();
        }

        if (isSquadron()) {
            return targetShip.getSquadron();
        }

        return 0;
    }

    public boolean isAnyKindOfUnique() {
        return DataUtils.isAnyKindOfUnique(this);
    }

    public boolean isTech() {
        return mUpType.equals("Tech");
    }

    public boolean isBorg() {
        return mUpType.equals("Borg");
    }

    public boolean isSquadron() {
        return "Squadron".equals(mUpType);
    }

    public boolean isCrew() {
        return mUpType.equals(Constants.CREW_TYPE);
    }

    public boolean isWeapon() {
        return mUpType.equals("Weapon");
    }

    public boolean isCostFiveOrLess() {
        return 5 >= mCost;
    }

    public boolean isTalent() {
        return mUpType.equals("Talent");
    }

    public boolean isCaptain() {
        return mUpType.equals("Captain");
    }

    public boolean isAdmiral() {
        return mUpType.equals("Admiral");
    }

    public boolean isFleetCaptain() {
        return mUpType.equals("Fleet Captain");
    }

    public boolean isOfficer() {
        return mUpType.equals(Constants.OFFICER_TYPE);
    }

    public boolean isDominion() {
        return DataUtils.targetHasFaction("Dominion", this);
    }

    public boolean isKlingon() { return DataUtils.targetHasFaction(Constants.KLINGON, this); }

    public boolean isBorgFaction() {
        return DataUtils.targetHasFaction(Constants.BORG, this);
    }

    public boolean isRomulan() {
        return DataUtils.targetHasFaction(Constants.ROMULAN, this);
    }

    public boolean isVulcan() {
        return DataUtils.targetHasFaction(Constants.VULCAN, this);
    }

    public boolean isIndependent() {
        return DataUtils.targetHasFaction(Constants.INDEPENDENT, this);
    }

    public boolean isKazon() {
        return DataUtils.targetHasFaction(Constants.KAZON, this);
    }

    public boolean isMirrorUniverse() {
        return DataUtils.targetHasFaction(Constants.MIRROR_UNIVERSE, this);
    }

    public boolean isQContinuum() {
        return DataUtils.targetHasFaction("Q Continuum", this);
    }
    public String targetShipClass() {

        if (mSpecial.equals("OnlyForRomulanScienceVessel")) {
            return "Romulan Science Vessel";
        } else if (mSpecial.equals("OnlyForRaptorClassShips")) {
            return "Raptor Class";
        }

        return "";
    }

    @Override
    public boolean isPlaceholder() {
        return getPlaceholder();
    }

    private String upSortType() {
        if (isTalent()) {
            return "AATalent";
        }
        return mUpType;
    }

    public int compareTo(Upgrade upgrade) {
        String upTypeMe = upSortType();
        String upTypeOther = upgrade.upSortType();
        int r = upTypeMe.compareTo(upTypeOther);
        if (r == 0) {
            boolean selfIsPlaceholder = isPlaceholder();
            boolean otherIsPlaceholder = upgrade.isPlaceholder();

            if (selfIsPlaceholder == otherIsPlaceholder) {
                return getTitle().compareToIgnoreCase(upgrade.getTitle());
            }

            if (selfIsPlaceholder) {
                return 1;
            }

            return -1;
        }

        if (upTypeMe.equals("Captain")) {
            return -1;
        }

        if (upTypeOther.equals("Captain")) {
            return 1;
        }

        return r;
    }

    public String getPlainDescription() {
        if (isPlaceholder()) {
            return getTitle();
        }

        return String.format("%s (%s)", getTitle(), getUpType());
    }

    public int calculateCostForShip(EquippedShip equippedShip, EquippedUpgrade equippedUpgrade) {
        if (isPlaceholder()) {
            return 0;
        }

        int cost = getCost();
        Ship ship = equippedShip.getShip();
        if (ship == null) {
            ship = Ship.nullShip();
        }

        String shipFaction = ship.getFaction();
        boolean shipIsSideboard = equippedShip.isResourceSideboard();
        if ("dorsal_phaser_array_71531".equals(this.getExternalId())) {
            if (shipIsSideboard) {
                cost = 6;
            } else {
                cost = ship.getAttack() + 1;
            }
        }
        String upgradeFaction = mFaction;
        Captain captain = equippedShip.getCaptain();

        if (isCaptain()) {
            Captain selfCaptain = (Captain) this;
            if (selfCaptain.isZeroCost()) {
                return 0;
            }
        }

        FleetCaptain fleetCaptain = equippedShip.getFleetCaptain();
        String fleetCaptainSpecial = equippedShip.getSquad().getFleetCaptainSpecial();
        String captainSpecial = null == captain ? "" : captain.getSpecial();
        String upgradeSpecial = getSpecial();
        if ("OnlyFedShipHV4CostPWVP1".equals(upgradeSpecial)) {
            cost = ship.getAttack() + 1;
        }
        if (isTalent()) {
            if (captainSpecial.equals("BaselineTalentCostToThree")
                    && upgradeFaction.equals("Federation") && !shipIsSideboard) {
                cost = 3;
            }
            if (null != fleetCaptain && 0 < fleetCaptain.getTalentAdd()) {
                if (equippedShip.getTalent() > equippedShip.allUpgradesOfType("Talent").size()) {
                    EquippedUpgrade mostExpensiveTalent = equippedShip.mostExpensiveUpgradeOfType("Talent");
                    if (null != mostExpensiveTalent && this == mostExpensiveTalent.getUpgrade()
                            && equippedUpgrade == mostExpensiveTalent) {
                        cost = 0;
                    }
                }
            }
        } else if (isCrew()) {
            if ((captainSpecial.equals("CrewUpgradesCostOneLess") || captainSpecial.equals("hugh_71522"))
                    && !shipIsSideboard) {
                cost -= 1;
            }
            if ("CrewUpgradesCostOneLess".equals(fleetCaptainSpecial)) {
                cost -= 1;
            }
            if (upgradeSpecial.equals("costincreasedifnotromulansciencevessel")) {
                if (!ship.isRomulanScienceVessel()) {
                    cost += 5;
                }
            }
        } else if (isWeapon()) {
            if (captainSpecial.equals("WeaponUpgradesCostOneLess")) {
                cost -= 1;
            }
            if (captainSpecial.equals("AddOneWeaponAllKazonMinusOne")) {
                if (isKazon()) {
                    cost -= 1;
                }
            }
            if ("WeaponUpgradesCostOneLess".equals(fleetCaptainSpecial)) {
                cost -= 1;
            }
            if (null != equippedShip.containsUpgrade(Universe.getUniverse().getUpgrade("romulan_hijackers_71802"))) {
                if (!isBorgFaction()) {
                    cost -= 1;
                }
            }
        } else if (isTech()) {
            if ("VulcanAndFedTechUpgradesMinus2".equals(captainSpecial) &&
                    ("Federation".equals(upgradeFaction) || "Vulcan".equals(upgradeFaction))) {
                cost -= 2;
            }
            if ("TechUpgradesCostOneLess".equals(fleetCaptainSpecial)) {
                cost -= 1;
            }
            if ("u_s_s_pegasus_71801".equals(ship.getExternalId())) {
                cost -= 1;
            }
            if (null != equippedShip.containsUpgrade(Universe.getUniverse().getUpgrade("romulan_hijackers_71802"))) {
                if (!isBorgFaction()) {
                    cost -= 1;
                }
            }
        }

        if (captain.getExternalId().equals("k_temoc_72009")) {
            if (isKlingon()) {
                cost -= 1;
            }
        }
        if (upgradeSpecial.equals("costincreasedifnotbreen")) {
            if (!ship.isBreen()) {
                cost += 5;
            }
        } else if (upgradeSpecial.equals("PenaltyOnShipOtherThanDefiant")) {
            if (!ship.isDefiant()) {
                cost += 5;
            }
        } else if (upgradeSpecial.equals("PlusFivePointsNonJemHadarShips")) {
            if (!ship.isJemhadar()) {
                cost += 5;
            }
        } else if ("PlusFourIfNotGornRaider".equals(upgradeSpecial)) {
            if (!ship.isGornRaider()) {
                cost += 4;
            }
        } else if (upgradeSpecial.equals("PlusFiveIfNotRemanWarbird")) {
            if (!ship.isRemanWarbird()) {
                cost += 5;
            }
        } else if (upgradeSpecial.equals("PenaltyOnShipOtherThanKeldonClass")) {
                if (!ship.isKeldon()) {
                cost += 5;
            }
        } else if (upgradeSpecial.equals("PlusFiveOnNonSpecies8472")) {
                if (!ship.isSpecies8472()) {
                cost += 5;
            }
        } else if (upgradeSpecial.equals("PlusFiveForNonKazon")) {
                if (!ship.isKazon()) {
                cost += 5;
            }
        } else if (upgradeSpecial.equals("CostPlusFiveExceptBajoranInterceptor")
                || upgradeSpecial.equals("PhaserStrike")) {
            if (!ship.isBajoranInterceptor()) {
                cost += 5;
            }
        } else if (upgradeSpecial.equals("PlusFiveIfNotBorgShip")) {
                if (!ship.isBorg()) {
                cost += 5;
            }
        } else if ("PlusFiveIfNotRomulan".equals(upgradeSpecial)) {
                if (!ship.isRomulan()) {
                cost += 5;
            }
        } else if (upgradeSpecial.equals("PlusFiveIfNotRaven")) {
                if (!ship.isRaven()) {
                cost += 5;
            }
        } else if (upgradeSpecial.equals("PlusFiveIfNotMirrorUniverse")) {
            if (!ship.isMirrorUniverse()) {
                cost += 5;
            }
        } else if (upgradeSpecial.equals("PlusFourIfNotPredatorClass")) {
            if (!ship.isPredatorClass()) {
                cost += 4;
            }
        } else if ("PlusFiveIfNotGalaxyIntrepidSovereign".equalsIgnoreCase(upgradeSpecial)) {
            if (!ship.isGalaxy() && !ship.isIntrepid() && !ship.isSovereign()) {
                cost += 5;
            }
        } else if (captainSpecial.equals("AllUpgradesMinusOneOnIndepedentShip")
                && DataUtils.targetHasFaction(Constants.INDEPENDENT,ship) && (!this.isCaptain() && !this.isAdmiral())) {
            cost -= 1;
        } else if ("PlusFiveIfNotRegentsFlagship".equals(upgradeSpecial) && !ship.isRegentsFlagship()) {
            cost += 5;
        } else if ("PlusFivePointsNonHirogen".equals(upgradeSpecial) && !ship.getShipClass().contains("Hirogen")) {
            cost += 5;
        } else if ("PlusFiveIfNotKlingon".equals(upgradeSpecial) && !ship.isKlingon()) {
            cost += 5;
        } else if ("Plus4NotPrometheus".equals(upgradeSpecial)) {
            if (!ship.getTitle().equals("U.S.S. Prometheus")) {
                cost += 4;
            }
        } else if ("Plus3NotKlingonAndNoMoreThanOnePerShip".equals(upgradeSpecial)) {
            if (!isKlingon()) {
                cost += 3;
            }
        } else if ("Plus2NotRomulanAndNoMoreThanOnePerShip".equals(upgradeSpecial)) {
            if (!isRomulan()) {
                cost += 2;
            }
        } else if (upgradeSpecial.startsWith("Plus3NotShipClass_")) {
            String reqClass = upgradeSpecial.substring(18);
            if (!ship.getShipClass().replace(" ", "_").equals(reqClass)) {
                cost += 3;
            }
        } else if (upgradeSpecial.startsWith("Plus3NotShip_")) {
            String reqShip = upgradeSpecial.substring(13);
            if (!ship.getTitle().replace(" ", "_").equals(reqShip)) {
                cost += 3;
            }
        } else if (upgradeSpecial.startsWith("Plus4NotShipClass_")) {
            String reqClass = upgradeSpecial.substring(18);
            if (!ship.getShipClass().replace(" ", "_").equals(reqClass)) {
                cost += 4;
            }
        } else if (upgradeSpecial.startsWith("Plus4NotShip_")) {
            String reqShip = upgradeSpecial.substring(13);
            if (!ship.getTitle().replace(" ", "_").equals(reqShip)) {
                cost += 4;
            }
        } else if (upgradeSpecial.startsWith("Plus5NotShipClass_")) {
            String reqClass = upgradeSpecial.substring(18);
            if (!ship.getShipClass().replace(" ", "_").equals(reqClass)) {
                cost += 5;
            }
        } else if (upgradeSpecial.startsWith("Plus5NotShip_")) {
            String reqShip = upgradeSpecial.substring(13);
            if (!ship.getTitle().replace(" ", "_").equals(reqShip)) {
                cost += 5;
            }
        } else if (upgradeSpecial.startsWith("Plus6NotShipClass_")) {
            String reqClass = upgradeSpecial.substring(18);
            if (!ship.getShipClass().replace(" ", "_").equals(reqClass)) {
                cost += 6;
            }
        } else if (upgradeSpecial.startsWith("Plus6NotShip_")) {
            String reqShip = upgradeSpecial.substring(13);
            if (!ship.getTitle().replace(" ", "_").equals(reqShip)) {
                cost += 6;
            }
        }
        if (captainSpecial.equals("OneDominionUpgradeCostsMinusTwo") && !shipIsSideboard) {
            if (isDominion()) {
                EquippedUpgrade most = equippedShip.mostExpensiveUpgradeOfFaction("Dominion");
                if (most != null && this == most.getUpgrade() && most == equippedUpgrade) {
                    cost -= 2;
                }
            }
        } else if (captainSpecial.equals("AddTwoCrewSlotsDominionCostBonus") && !shipIsSideboard) {
            if (isDominion()) {
                ArrayList<EquippedUpgrade> all = equippedShip.allUpgradesOfFactionAndType(
                        "Dominion", "Crew");
                int index = -1;
                for (int i = 0; i < all.size(); ++i) {
                    EquippedUpgrade eu = all.get(i);
                    Upgrade upgradeToTest = eu.getUpgrade();
                    if (this == upgradeToTest && eu == equippedUpgrade) {
                        index = i;
                        break;
                    }
                }

                if (index != -1 && index < 2) {
                    cost -= 1;
                }
            }
        } else if (captainSpecial.equals("AddsHiddenTechSlot") && this.isTech() && !shipIsSideboard) {
            ArrayList<EquippedUpgrade> allTechUpgrades = equippedShip.allUpgradesOfFactionAndType(
                    null, "Tech");
            EquippedUpgrade most = null;
            for (EquippedUpgrade eu : allTechUpgrades) {
                Upgrade targetTechUpgrade = eu.getUpgrade();
                if (targetTechUpgrade != null) {
                    String targetSpecial = targetTechUpgrade.getSpecial();
                    if (targetSpecial == null || !sIneligibleTechUpgrades.contains(targetSpecial)) {
                        most = eu;
                        break;
                    }
                }
            }
            if (most != null && most.isEqualToUpgrade(this)) {
                cost = 3;
            }
        }
        if (!DataUtils.factionsMatch(ship, this)
                && !equippedShip.isResourceSideboard()
                && !DataUtils.targetHasFaction(equippedShip.getFlagshipFaction(), this)) {
            if (captainSpecial.equals("UpgradesIgnoreFactionPenalty") && !isCaptain() && !isAdmiral()) {
                // do nothing
            } else if (captainSpecial.equals("CaptainIgnoresPenalty") && isCaptain()) {
                // do nothing
            } else if (this.isQContinuum()) {
                // do nothing
            } else if (captainSpecial.equals("NoPenaltyOnFederationOrBajoranShip") && isCaptain()) {
                if (!(ship.isFederation() || ship.isBajoran())) {
                    cost += 1;
                }
            } else if (captainSpecial.equals("NoPenaltyOnFederationShip") && isCaptain()) {
                if (!(ship.isFederation())) {
                    cost += 1;
                }
            } else if (upgradeSpecial.equals("NoPenaltyOnKlingonShip") && !ship.getFaction().equals("Klingon")) {
                cost += 1;
            } else if (captainSpecial.equals("CaptainAndTalentsIgnoreFactionPenalty")
                    && (isTalent() || isCaptain())) {
                // do nothing
            } else if (captainSpecial.equals("lore_71522") && isTalent()) {
                // do nothing
            } else if (captainSpecial.equals("hugh_71522") && isBorgFaction()) {
                // do nothing
            } else if (null != equippedShip.containsUpgrade(Universe.getUniverse().getUpgrade("romulan_hijackers_71802")) && isRomulan()) {
                // do nothing
            } else if (captain.getExternalId().equals("k_temoc_72009")) {
                if (isAdmiral()) {
                    cost += 6;
                } else {
                    cost += 2;
                }
            } else if (isAdmiral()) {
                cost += 3;
            } else if (isCaptain() && null != fleetCaptain
                    && fleetCaptain.isIndependent()
                    && ship.isIndependent()) {
                // do nothing
            } else if (ship.isVulcan() && "add_one_tech_no_faction_penalty_on_vulcan".equals(upgradeSpecial)) {
                // do nothing
            } else if ("elim_garak_71786".equals(this.getExternalId())) {
                // do nothing
            } else {
                cost += 1;
            }
        }

        if (ship != null && ship.getExternalId().equals(Constants.TACTICAL_CUBE_138)
                && getExternalId().equals(Constants.BORG_ABLATIVE_ARMOR)) {
            cost = 7;
        }

        if (isWeapon() && null != equippedShip.containsUpgradeWithName("Sakonna") && cost <= 5) {
            cost -= 2;
        }

        if ("PlusFiveIfSkillOverFive".equals(upgradeSpecial) && 5 < captain.getSkill()) {
            cost += 5;
        }

        if (cost < 0) {
            cost = 0;
        }

        return cost;

    }

    public boolean modifiesSlotsOfEquippedShip() {
        String special = getSpecial();
        if (special == null) {
            return false;
        }
        if (special.equalsIgnoreCase("AddTwoWeaponSlots")) {
            return true;
        }
        if (special.equalsIgnoreCase("AddsHiddenTechSlot")) {
            return true;
        }
        if (special.equalsIgnoreCase("addonetechslot")) {
            return true;
        }
        if (special.equalsIgnoreCase("addoneweaponslot")) {
            return true;
        }
        if (special.equalsIgnoreCase("AddTwoCrewSlotsDominionCostBonus")) {
            return true;
        }
        if (special.equalsIgnoreCase("VulcanHighCommand")) {
            return true;
        }
        if (special.equalsIgnoreCase("Add_Crew_1")) {
            return true;
        }
        if (special.equalsIgnoreCase("only_suurok_class_limited_weapon_hull_plus_1")) {
            return true;
        }
        if (special.equalsIgnoreCase("add_one_tech_no_faction_penalty_on_vulcan")) {
            return true;
        }
        if ("quark_weapon_71786".equalsIgnoreCase(this.getExternalId())
                || "quark_71786".equalsIgnoreCase(this.getExternalId())) {
            return true;
        }
        if (special.equals("Add2HiddenCrew5")) {
            return true;
        }
        return false;
    }

    public int additionalTalentSlots() {
        String externalId = getExternalId();
        if (externalId != null && externalId.equals("elim_garak_71786")) {
            return 1;
        }
        return 0;
    }

    public int additionalWeaponSlots() {
        String special = getSpecial();
        if ("AddsOneWeaponOneTech".equalsIgnoreCase(special)
                || "sakonna_gavroche".equalsIgnoreCase(special)
                || "only_suurok_class_limited_weapon_hull_plus_1".equalsIgnoreCase(special)
                || "only_suurok_class_limited_weapon_hull_plus_1".equalsIgnoreCase(special)
                || "AddOneWeaponAllKazonMinusOne".equalsIgnoreCase(special)
                || "addoneweaponslot".equalsIgnoreCase(special)
                || "quark_weapon_71786".equals(this.getExternalId())
                || "AddHiddenWeapon".equalsIgnoreCase(special)) {
            return 1;
        }
        if ("AddTwoWeaponSlots".equalsIgnoreCase(special)) {
            return 2;
        }
        return 0;
    }

    public int additionalCrewSlots() {
        String special = getSpecial();
        if (special != null) {
            if (special.equalsIgnoreCase("Add_Crew_1")) {
                return 1;
            }
            String externalId = getExternalId();
            if (externalId != null) {
                if (externalId.equals("vulcan_high_command_0_2_71446") || "Add2HiddenCrew5".equalsIgnoreCase(special)) {
                    return 2;
                }
                if (externalId.equals("vulcan_high_command_1_1_71446")) {
                    return 1;
                }
            }
        }
        return 0;
    }

    public int additionalTechSlots() {
        String special = getSpecial();
        if (special != null) {
            if (special.equalsIgnoreCase("AddsOneWeaponOneTech")
                    || "addonetechslot".equalsIgnoreCase(special)
                    || "add_one_tech_no_faction_penalty_on_vulcan".equalsIgnoreCase(special)) {
                return 1;
            }
        }
        String externalId = getExternalId();
        if (externalId != null) {
            if (externalId.equals("vulcan_high_command_2_0_71446")) {
                return 2;
            }
            if (externalId.equals("vulcan_high_command_1_1_71446")
                    || externalId.equals("quark_71786")
                    || externalId.equals("systems_upgrade_71998p")
                    || externalId.equals("systems_upgrade_c_71998p")
                    || externalId.equals("systems_upgrade_w_71998p")
                    ) {
                return 1;
            }
        }
        return 0;
    }

    public int additionalBorgSlots() {
        String special = getSpecial();
        if (special != null) {
            if ("OnlyNonBorgShipAndNonBorgCaptain".equals(special)) {
                return 1;
            }
        }
        return 0;
    }
}
