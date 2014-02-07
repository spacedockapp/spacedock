package com.funnyhatsoftware.spacedock.test;

import android.test.AndroidTestCase;

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
		assertEquals(4, entD.attack);
		assertEquals("U.S.S. Enterprise-D", entD.title);
	}

}
