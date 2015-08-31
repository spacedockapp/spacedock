package com.funnyhatsoftware.spacedock;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.widget.Toast;

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

    private static void storeSeenSets(SharedPreferences prefs, java.util.Set<String> seenSetIds) {
        prefs.edit()
                .putStringSet(SetPreference.PREF_KEY_SEEN_SET_ID, seenSetIds)
                .apply();
    }

    private static void storeSelectedAndSeenSets(SharedPreferences prefs,
                                                 java.util.Set<String> selectedSetIds,
                                                 java.util.Set<String> seenSetIds) {
        prefs.edit()
                .putStringSet(SetPreference.PREF_KEY_SET_ID, selectedSetIds)
                .putStringSet(SetPreference.PREF_KEY_SEEN_SET_ID, seenSetIds)
                .apply();
    }

    public static void loadSetPreferences(Context context) {
        Universe universe = Universe.getUniverse();
        java.util.Set<String> allSetIds = universe.getAllSetIds();

        SharedPreferences sharedPrefs = PreferenceManager.getDefaultSharedPreferences(context);
        java.util.Set<String> setIds = sharedPrefs.getStringSet(
                SetPreference.PREF_KEY_SET_ID, allSetIds);
        java.util.Set<String> seenSetIds = sharedPrefs.getStringSet(
                SetPreference.PREF_KEY_SEEN_SET_ID, allSetIds);

        if (setIds == null && seenSetIds == null) {
            throw new IllegalStateException("unable to load set preference or defaults!");
        }

        if (!seenSetIds.containsAll(allSetIds) || !allSetIds.containsAll(seenSetIds)) {
            // Seen Sets differ from those in universe
            String toastText = universe.getSetChangeString(seenSetIds);

            if (sharedPrefs.getBoolean("pref_key_auto_add_new_sets", true)) {
                // auto add newly seen sets - ask universe for valid selected sets, plus new ones
                setIds = universe.getSetSelectionPlusNewSets(setIds, seenSetIds);

                storeSelectedAndSeenSets(sharedPrefs, setIds, allSetIds);
                toastText += " enabled, and added to library.";
            } else {
                storeSeenSets(sharedPrefs, seenSetIds);
                toastText += " added to library.";
            }
            Toast.makeText(context, toastText, Toast.LENGTH_LONG).show();
        } else if (seenSetIds == allSetIds) {
            storeSeenSets(sharedPrefs, seenSetIds);
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
