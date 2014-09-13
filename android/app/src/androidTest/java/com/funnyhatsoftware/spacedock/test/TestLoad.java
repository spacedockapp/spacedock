
package com.funnyhatsoftware.spacedock.test;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

import android.util.Log;

import com.funnyhatsoftware.spacedock.data.Captain;
import com.funnyhatsoftware.spacedock.data.Flagship;
import com.funnyhatsoftware.spacedock.data.Maneuver;
import com.funnyhatsoftware.spacedock.data.Resource;
import com.funnyhatsoftware.spacedock.data.Set;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Ship;
import com.funnyhatsoftware.spacedock.data.ShipClassDetails;
import com.funnyhatsoftware.spacedock.data.Upgrade;

public class TestLoad extends BaseTest {
    public TestLoad() {
        super();
    }

    public void testBasics() {
        assertEquals("Ship count wrong", 112, universe.getShips().size());
        Ship entD = universe.getShip("1001");
        assertNotNull("Couldn't get ship", entD);
        assertEquals(4, entD.getAttack());
        ShipClassDetails details = entD.getShipClassDetails();
        assertNotNull("Couldn't get ship details", details);
        assertEquals("wrong front arc", "90", details.getFrontArc());
        Maneuver maneuver = details.getManeuver(-2, "straight");
        assertNotNull("Couldn't backup 2", maneuver);
        assertEquals(-2, maneuver.getSpeed());
        assertEquals("U.S.S. Enterprise-D", entD.getTitle());
        assertTrue("U.S.S. Enterprise-D should be unique", entD.getUnique());

        Captain picard = universe.getCaptain("2001");
        assertNotNull("Couldn't get captain", picard);
        assertEquals(9, picard.getSkill());
        assertEquals("Jean-Luc Picard", picard.getTitle());
        assertTrue("Picard should be unique", picard.getUnique());

        Upgrade romulanPilot = universe.getUpgrade("3102");
        assertNotNull("Couldn't get upgrade", romulanPilot);
        assertEquals("Romulan Pilot", romulanPilot.getTitle());
        assertEquals(2, romulanPilot.getCost());
        assertFalse("Romulan Pilot should not be unique",
                romulanPilot.getUnique());

        Flagship fs = universe.getFlagship("6002");
        assertNotNull("Couldn't get flagship", fs);
        assertEquals("attack value wrong", 1, fs.getAttack());
        assertEquals("hull value wrong", 0, fs.getHull());
        assertEquals("faction wrong", "Independent", fs.getFaction());

        Resource tokens = universe.getResource("4002");
        assertNotNull("Couldn't get resource", tokens);
        assertEquals("resource cost value wrong", 5, tokens.getCost());

        Set coreSet = universe.getSet("71120");
        assertNotNull("Couldn't get core set", coreSet);
        ArrayList<SetItem> setItems = coreSet.getItems();
        Comparator<SetItem> comparator = new Comparator<SetItem>() {
            public int compare(SetItem arg0, SetItem arg1) {
                return arg0.getTitle().compareTo(arg1.getTitle());
            }

        };
        Collections.sort(setItems, comparator);
        for (SetItem item : setItems) {
            Log.i("spacedock", item.getTitle());
        }
        assertEquals("Count of items in core set wrong", 36, setItems.size());

        Set reliantSet = universe.getSet("71121");
        assertNotNull("Couldn't get core set", reliantSet);
        assertEquals("Count of items in reliant expansion wrong", 12,
                reliantSet.getItems().size());
    }

}
