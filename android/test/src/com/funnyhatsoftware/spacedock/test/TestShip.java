package com.funnyhatsoftware.spacedock.test;

import java.io.IOException;
import java.io.InputStream;

import javax.xml.parsers.ParserConfigurationException;

import org.xml.sax.SAXException;

import android.content.res.AssetManager;
import android.test.AndroidTestCase;
import android.text.TextUtils;
import android.util.Log;

import com.funnyhatsoftware.spacedock.DataLoader;
import com.funnyhatsoftware.spacedock.Universe;

public class TestShip extends AndroidTestCase {
	Universe universe;

	public TestShip() {
		super();
	}

	public void setUp() throws IOException, ParserConfigurationException,
			SAXException {
		universe = new Universe();
		AssetManager am = getContext().getAssets();
		String[] files = am.list("");
		Log.i("spacedock", "files = " + TextUtils.join(",", files));
		InputStream is = am.open("data.xml");
		DataLoader loader = new DataLoader(universe, is);
		loader.load();
	}

	public void testLoad() {
	}

}
