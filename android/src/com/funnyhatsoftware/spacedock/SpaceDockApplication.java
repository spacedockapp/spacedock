package com.funnyhatsoftware.spacedock;

import java.io.IOException;

import javax.xml.parsers.ParserConfigurationException;

import org.json.JSONException;
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
            Universe universe = Universe.getUniverse(getApplicationContext());
            universe.restore(this);
        } catch (ParserConfigurationException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (SAXException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        SetItemHolderFactory.initialize();

        loadSetPreferences(this);
    }

    /**
     * Load Set selection from shared preferences
     *
     * TODO: add never-before-seen sets automatically to pref_key_set_selection.
     *
     * This would involve:
     *
     * 1) When storing the preference, store all sets seen so far.
     *
     * 2) When loading the preference here, if the set of seen sets (ugh) is any different from
     *    what's in the Universe, store a new value for the set preference that is:
     *    (setsInUniverse - pref_previouslySeen) + (setsInUniverse & pref_setSelection)
     *    and update the seen set of sets
     */
    public static void loadSetPreferences(Context context) {
        SharedPreferences sharedPrefs = PreferenceManager.getDefaultSharedPreferences(context);
        java.util.Set<String> setSelection = sharedPrefs.getStringSet(
                "pref_key_set_selection", null);
        updateSetPreferences(setSelection);
    }

    /**
     * Push updates to set selection into Universe
     *
     * This must *only* be called at app startup, or when changes to user
     * preferences are made by SetPreference changes.
     */
    public static void updateSetPreferences(java.util.Set<String> setSelection) {
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
