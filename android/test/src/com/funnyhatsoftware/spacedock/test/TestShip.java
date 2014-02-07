package com.funnyhatsoftware.spacedock.test;

import android.test.AndroidTestCase;

import com.funnyhatsoftware.spacedock.data.Captain;
import com.funnyhatsoftware.spacedock.data.Ship;
import com.funnyhatsoftware.spacedock.data.Universe;

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
		assertEquals(4, entD.getAttack());
		assertEquals("U.S.S. Enterprise-D", entD.getTitle());
		
		Captain picard = universe.captains.get("2001");
		assertEquals(9, picard.getSkill());
		assertEquals("Jean-Luc Picard", picard.getTitle());
	}

}
