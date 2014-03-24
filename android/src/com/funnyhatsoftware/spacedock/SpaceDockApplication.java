package com.funnyhatsoftware.spacedock;

import java.io.IOException;

import javax.xml.parsers.ParserConfigurationException;

import org.xml.sax.SAXException;

import android.app.Application;

import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.holder.SetItemHolderFactory;

public class SpaceDockApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        try {
            Universe.getUniverse(getApplicationContext());
        } catch (ParserConfigurationException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (SAXException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        SetItemHolderFactory.initialize();
    }
}
