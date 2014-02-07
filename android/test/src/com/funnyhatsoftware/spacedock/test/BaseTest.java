package com.funnyhatsoftware.spacedock.test;

import com.funnyhatsoftware.spacedock.data.Universe;

import android.test.AndroidTestCase;

public class BaseTest extends AndroidTestCase {

	protected Universe universe;

	public BaseTest() {
		super();
	}

	public void setUp() {
		universe = Universe.getUniverse(getContext());
	}

}