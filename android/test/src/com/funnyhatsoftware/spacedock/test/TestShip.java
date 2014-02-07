package com.funnyhatsoftware.spacedock.test;

import android.test.AndroidTestCase;

import com.funnyhatsoftware.spacedock.data.Captain;
import com.funnyhatsoftware.spacedock.data.Set;
import com.funnyhatsoftware.spacedock.data.Ship;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.data.Upgrade;

public class TestShip extends AndroidTestCase {
	Universe universe;

	public TestShip() {
		super();
	}

	public void setUp() {
		universe = Universe.getUniverse(getContext());
	}

	public void testLoad() {
		Ship entD = universe.ships.get("1001");
		assertNotNull("Couldn't get ship", entD);
		assertEquals(4, entD.getAttack());
		assertEquals("U.S.S. Enterprise-D", entD.getTitle());
		assertTrue("U.S.S. Enterprise-D should be unique", entD.getUnique());

		Captain picard = universe.captains.get("2001");
		assertNotNull("Couldn't get captain", picard);
		assertEquals(9, picard.getSkill());
		assertEquals("Jean-Luc Picard", picard.getTitle());
		assertTrue("Picard should be unique", picard.getUnique());

		Upgrade romulanPilot = universe.upgrades.get("3102");
		assertNotNull("Couldn't get upgrade", romulanPilot);
		assertEquals("Romulan Pilot", romulanPilot.getTitle());
		assertEquals(2, romulanPilot.getCost());
		assertFalse("Romulan Pilot should not be unique",
				romulanPilot.getUnique());

		Set coreSet = universe.sets.get("71120");
		assertNotNull("Couldn't get core set", coreSet);
		assertEquals("Count of items in core set wrong", 30, coreSet.getItems()
				.size());

		Set reliantSet = universe.sets.get("71121");
		assertNotNull("Couldn't get core set", reliantSet);
		assertEquals("Count of items in reliant expansion wrong", 12,
				reliantSet.getItems().size());
	}

}
