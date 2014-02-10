package com.funnyhatsoftware.spacedock;

import android.widget.TextView;

import com.funnyhatsoftware.spacedock.data.Captain;
import com.funnyhatsoftware.spacedock.data.Crew;
import com.funnyhatsoftware.spacedock.data.EquippedShip;
import com.funnyhatsoftware.spacedock.data.EquippedUpgrade;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Ship;
import com.funnyhatsoftware.spacedock.data.Tech;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.data.Upgrade;
import com.funnyhatsoftware.spacedock.data.Weapon;

import java.util.ArrayList;
import java.util.List;

public class EquipHelper {
    public static final int SLOT_TYPE_INVALID = -1;
    public static final int SLOT_TYPE_SHIP = 0;
    public static final int SLOT_TYPE_CAPTAIN = 1;
    public static final int SLOT_TYPE_CREW = 2;
    public static final int SLOT_TYPE_WEAPON = 3;
    public static final int SLOT_TYPE_TECH = 4;

    private static Class[] CLASS_FOR_SLOT = new Class[] {
            Ship.class,
            Captain.class,
            Crew.class,
            Weapon.class,
            Tech.class,
    };

    private static void insertShip(Ship ship, EquippedShip equippedShip) {
        assert(!ship.getEquippedShips().contains(equippedShip));

        Ship oldShip = equippedShip.getShip();
        if (oldShip != null) {
            oldShip.getEquippedShips().remove(equippedShip);
        }
        equippedShip.setShip(ship);
        ship.getEquippedShips().add(equippedShip);
    }

    public static void insertItem(String itemExternalId, EquippedShip equippedShip,
                int slotType, int slotIndex) {
        if (slotType == SLOT_TYPE_SHIP) {
            Ship ship = Universe.getUniverse().getShip(itemExternalId);
            insertShip(ship, equippedShip);
        } else if (slotType == SLOT_TYPE_CAPTAIN) {
            Captain captain = Universe.getUniverse().getCaptain(itemExternalId);
            equippedShip.equipUpgrade(captain, slotIndex);
        } else {
            Upgrade upgrade = Universe.getUniverse().getUpgrade(itemExternalId);
            equippedShip.equipUpgrade(upgrade, slotIndex);
        }
    }

    public static String getIdFromSlot(EquippedShip equippedShip, int slotType, int slotIndex) {
        if (slotType == SLOT_TYPE_SHIP) {
            if (equippedShip.getShip() == null) return null;
            return equippedShip.getShip().getExternalId();
        }

        EquippedUpgrade eu = equippedShip.getUpgradeAtSlot(CLASS_FOR_SLOT[slotType], slotIndex);
        return eu == null ? null : eu.getUpgrade().getExternalId();
    }

    public static void updateTotalCost(EquippedShip equippedShip, TextView textView) {
        if (equippedShip.getShip() == null) {
            textView.setText("-");
            return;
        }

        int total = equippedShip.calculateCost();
        textView.setText(Integer.toString(total));
    }

    public static void updateSlotCost(EquippedShip equippedShip,
            TextView titleTextView, TextView costTextView, int slotType, int slotIndex) {
        if (slotType == SLOT_TYPE_SHIP) {
            if (equippedShip.getShip() != null) {
                titleTextView.setText(equippedShip.getShip().getTitle());
                costTextView.setText(Integer.toString(equippedShip.getShip().getCost()));
                return;
            }
        } else {
            EquippedUpgrade equippedUpgrade =
                    equippedShip.getUpgradeAtSlot(CLASS_FOR_SLOT[slotType], slotIndex);
            if (equippedUpgrade != null) {
                titleTextView.setText(equippedUpgrade.getUpgrade().getTitle());
                costTextView.setText(Integer.toString(equippedUpgrade.calculateCost()));
                return;
            }
        }

        // TODO: resource strings
        titleTextView.setText("EMPTY SLOT");
        costTextView.setText("-");
    }

    // TODO: refactor once SetItemListFragment's adapter is fleshed out
    public static class SetItemWrapper {
        SetItem item;
        SetItemWrapper(SetItem item) {
            this.item = item;
        }
        public String getExternalId() { return item.getExternalId(); }

        @Override
        public String toString() {
            return item.getTitle() + " " + item.getCost();
        }
    }

    public static List<SetItemWrapper> getItemsForSlot(int slotType) {
        List<SetItemWrapper> items = new ArrayList<SetItemWrapper>();
        Universe universe = Universe.getUniverse();

        if (slotType == SLOT_TYPE_CAPTAIN) {
            for (int i = 0; i < universe.captains.size(); i++) {
                items.add(new SetItemWrapper(universe.captains.valueAt(i)));
            }
            return items;
        } else if (slotType == SLOT_TYPE_SHIP) {
            for (int i = 0; i < universe.ships.size(); i++) {
                items.add(new SetItemWrapper(universe.ships.valueAt(i)));
            }
            return items;
        }

        for (int i = 0; i < universe.upgrades.size(); i++) {
            Upgrade upgrade = universe.upgrades.valueAt(i);
            if (upgrade.getClass() == CLASS_FOR_SLOT[slotType]) {
                items.add(new SetItemWrapper(upgrade));
            }
        }
        return items;
    }
}
