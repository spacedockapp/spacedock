package com.funnyhatsoftware.spacedock.test;

import java.io.IOException;
import java.io.InputStream;

import javax.xml.parsers.ParserConfigurationException;

import org.xml.sax.SAXException;

import android.content.res.AssetManager;
import android.test.AndroidTestCase;
import android.text.TextUtils;
import android.util.Log;

import com.funnyhatsoftware.spacedock.data.DataLoader;
import com.funnyhatsoftware.spacedock.data.Ship;
import com.funnyhatsoftware.spacedock.data.Universe;

public class TestShip extends AndroidTestCase {
	Universe universe;

	public TestShip() {
		super();
	}

	public void setUp() throws IOException, ParserConfigurationException,
			SAXException {
		universe = new Universe();
		AssetManager am = getContext().getAssets();
		InputStream is = am.open("data.xml");
		DataLoader loader = new DataLoader(universe, is);
		loader.load();
	}

	public void testLoad() {
		Ship entD = universe.ships.get("1001");
		assertEquals(4, entD.attack);
		assertEquals("U.S.S. Enterprise-D", entD.title);
	}

}
