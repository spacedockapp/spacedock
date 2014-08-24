package com.funnyhatsoftware.spacedock;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.holder.SetItemHolderFactory;

import org.json.JSONException;
import org.xml.sax.SAXException;

import java.io.IOException;

import javax.xml.parsers.ParserConfigurationException;

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

    public static void loadSetPreferences(Context context) {
        SharedPreferences sharedPrefs = PreferenceManager.getDefaultSharedPreferences(context);

        Universe universe = Universe.getUniverse();
        java.util.Set<String> allSetIds = universe.getAllSetIds();

        java.util.Set<String> setIds = sharedPrefs.getStringSet(
                SetPreference.PREF_KEY_SET_ID, allSetIds);
        java.util.Set<String> seenSetIds = sharedPrefs.getStringSet(
                SetPreference.PREF_KEY_SEEN_SET_ID, allSetIds);

        // Check if seen Sets differ from Sets in universe
        if (setIds != null && seenSetIds != null
                && (!seenSetIds.containsAll(allSetIds) || !allSetIds.containsAll(seenSetIds))) {
            // ask universe for valid selected sets, plus any new ones
            setIds = universe.getSetSelectionPlusNewSets(setIds, seenSetIds);

            // new sets are observed, store new set preference in the background
            sharedPrefs.edit()
                    .putStringSet(SetPreference.PREF_KEY_SET_ID, setIds)
                    .putStringSet(SetPreference.PREF_KEY_SEEN_SET_ID, allSetIds)
                    .apply();
        }
        updateSetPreferences(setIds);
    }

    /**
     * Push updates to set selection into Universe
     *
     * This must *only* be called at app startup, or when changes to user
     * preferences are made by SetPreference changes.
     */
    public static void updateSetPreferences(java.util.Set<String> setIdSelection) {
        Universe universe = Universe.getUniverse();
        if (setIdSelection == null) {
            // no preference set, so default to all
            universe.includeAllSets();
        } else {
            // inform the universe of the user's set preference
            universe.includeSetsById(setIdSelection);
        }
    }
}
