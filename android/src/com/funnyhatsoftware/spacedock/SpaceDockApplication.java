package com.funnyhatsoftware.spacedock;

import java.io.IOException;

import javax.xml.parsers.ParserConfigurationException;

import org.xml.sax.SAXException;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

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

        loadSetPreferences(this);
    }

    public static void loadSetPreferences(Context context) {
        SharedPreferences sharedPrefs = PreferenceManager.getDefaultSharedPreferences(context);
        java.util.Set<String> setSelection = sharedPrefs.getStringSet(
                "pref_key_set_selection", null);

        Universe universe = Universe.getUniverse();
        if (setSelection == null) {
            // no preference set, so default to all
            universe.includeAllSets();
        } else {
            // inform the universe of the user's set preference
            universe.includeSetsByName(setSelection);
        }
    }
}
