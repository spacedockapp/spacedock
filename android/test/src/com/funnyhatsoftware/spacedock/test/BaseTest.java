
package com.funnyhatsoftware.spacedock.test;

import java.io.IOException;

import javax.xml.parsers.ParserConfigurationException;

import org.xml.sax.SAXException;

import com.funnyhatsoftware.spacedock.data.Universe;

import android.test.AndroidTestCase;

public class BaseTest extends AndroidTestCase {

    protected Universe universe;

    public BaseTest() {
        super();
    }

    public void setUp() throws ParserConfigurationException, SAXException, IOException {
        universe = Universe.getUniverse(getContext());
    }

}
