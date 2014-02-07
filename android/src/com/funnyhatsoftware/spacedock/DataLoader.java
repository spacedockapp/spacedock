package com.funnyhatsoftware.spacedock;

import java.io.IOException;
import java.io.InputStream;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.Locator;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;

import android.util.Log;

public class DataLoader extends DefaultHandler {
	Universe universe;
	String xmlFilePath;
	InputStream xmlInput;

	public DataLoader(Universe targetUniverse, InputStream xmlTargetInput) {
		universe = targetUniverse;
		xmlInput = xmlTargetInput;
	}

	public boolean load() throws ParserConfigurationException, SAXException,
			IOException {
		SAXParserFactory spf = SAXParserFactory.newInstance();
		SAXParser sp = spf.newSAXParser();

		XMLReader xr = sp.getXMLReader();

		xr.setContentHandler(this);

		xr.parse(new InputSource(xmlInput));
		return true;
	}

	@Override
	public void startElement(String uri, String localName, String qName,
			Attributes attributes) {
		Log.i("spacedock", "Starting element " + qName);
		// TODO Auto-generated method stub

	}

}
