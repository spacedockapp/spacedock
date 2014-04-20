package com.funnyhatsoftware.spacedock;

import android.content.Context;
import android.preference.MultiSelectListPreference;
import android.preference.Preference;
import android.util.AttributeSet;
import android.widget.Toast;

import com.funnyhatsoftware.spacedock.data.Set;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;

public class SetPreference extends MultiSelectListPreference
        implements Preference.OnPreferenceChangeListener {

    public static final String PREF_KEY_SET_ID = "pref_key_set_id_selection";
    public static final String PREF_KEY_SEEN_SET_ID = "pref_key_set_id_seen";

    @Deprecated
    public static final String PREF_KEY_SET_LEGACY = "pref_key_set_selection";

    java.util.Set<String> mObservedSetIds = new HashSet<String>();

    public SetPreference(Context context, AttributeSet attrs) {
        super(context, attrs);

        ArrayList<Set> sets = Universe.getUniverse().getAllSets();
        String[] setLabels = new String[sets.size()];
        String[] setValues = new String[sets.size()];

        Collections.sort(sets, new Set.SetComparator());

        for (int i = 0; i < sets.size(); i++) {
            setLabels[i] = sets.get(i).getProductName();
            setValues[i] = sets.get(i).getExternalId();
            mObservedSetIds.add(setValues[i]);
        }
        setEntries(setLabels);
        setEntryValues(setValues);
        setDefaultValue(mObservedSetIds); // each set enabled by default
        setOnPreferenceChangeListener(this);
    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        java.util.Set<String> newSets = (java.util.Set<String>) newValue;
        if (newSets == null || newSets.isEmpty()) {
            Toast.makeText(getContext(),
                    R.string.toast_invalid_set_selection, Toast.LENGTH_LONG).show();
            return false; // disallow update
        }
        SpaceDockApplication.updateSetPreferences(newSets);

        // there may a race here, since transaction not shared with the actual selection commit
        preference.getSharedPreferences().edit()
                .putStringSet(PREF_KEY_SEEN_SET_ID, mObservedSetIds)
                .commit();
        return true; // approve update, and allow it to be persisted
    }

    ////////////////////////////////////////////////////////////////////////////
    // Support for legacy property storage. Delete once the upgrade path is very unlikely.
    ////////////////////////////////////////////////////////////////////////////
    @Deprecated
    public static java.util.Set<String> getSetIdsFromLegacyNames(
            java.util.Set<String> setLegacyNames) {
        java.util.Set<String> selectionIds = new HashSet<String>();
        for (String[] legacyPair : sLegacyPairs) {
            String externalId = legacyPair[0];
            String legacyName = legacyPair[1];

            if (setLegacyNames.contains(legacyName)) {
                selectionIds.add(externalId);
            }
        }
        return selectionIds;
    }

    @Deprecated
    public static java.util.Set<String> getLegacySeen() {
        java.util.Set<String> seen = new HashSet<String>();
        for (String[] legacyPair : sLegacyPairs) {
            seen.add(legacyPair[0]);
        }
        return seen;
    }

    @Deprecated
    private static final String[][] sLegacyPairs = {
            {"71120", "Starter Set"},
            {"71121", "Federation U.S.S. Reliant Expansion Pack"},
            {"71122", "Federation U.S.S. Enterprise Expansion Pack"},
            {"71123", "Romulan I.R.W. Valdore Expansion Pack"},
            {"71124", "Romulan R.I.S. Apnex Expansion Pack"},
            {"71125", "Klingon I.K.S. Gr''oth Expansion Pack"},
            {"71126", "Klingon I.K.S. Negh''var Expansion Pack"},
            {"71127", "Dominion Kraxon Expansion Pack"},
            {"71128", "Dominion Gor Portas Expansion Pack"},
            {"71268", "Federation U.S.S. Defiant Expansion Pack"},
            {"71269", "Klingon I.K.S. Kronos One Expansion Pack"},
            {"71270", "Romulan I.R.W. Praetus Expansion Pack"},
            {"71271", "Dominion 5th Wing Patrol Ship 6 Expansion Pack"},
            {"71272", "Federation U.S.S. Excelsior Expansion Pack"},
            {"71273", "Klingon I.K.S. Koraga Expansion Pack"},
            {"71274", "Romulan R.I.S. Vo Expansion Pack"},
            {"71275", "Dominion Koranak Expansion Pack"},
            {"71276", "Federation U.S.S. Equinox Expansion Pack"},
            {"71278", "Romulan R.I.S. Gal Gath'thong Expansion Pack"},
            {"71279", "Dominion 4th Division Battleship Expansion Pack"},
            {"71280", "U.S.S. Voyager Expansion"},
            {"71281", "Bioship Alpha Expansion"},
            {"71282", "Nistrim Raider Expansion"},
            {"71283", "Borg Sphere 4270 Expansion"},
            {"71448", "Klingon I.K.S. Somraw Expansion Pack"},
            {"GenCon2013Promo", "Khan Singh GenCon 2013 Promo"},
            {"OP1Participation", "Dominion War OP1 Participation Prize"},
            {"OP1Prize", "Dominion War OP1 Competitive Prize"},
            {"OP2Participation", "Dominion War OP2 Participation Prize"},
            {"OP2Prize", "Dominion War OP2 Competitive Prize"},
            {"OP3Participation", "Dominion War OP3 Participation Prize"},
            {"OP3Prize", "Dominion War OP3 Competitive Prize"},
            {"OP4Participation", "Dominion War OP4 Participation Prize"},
            {"OP4Prize", "Dominion War OP4 Competitive Prize"},
            {"OP5Participation", "Dominion War OP5 Participation Prize"},
            {"OP5Prize", "Dominion War OP5 Competitive Prize"},
            {"OP6Participation", "Dominion War OP6 Participation Prize"},
            {"OP6Prize", "Dominion War OP6 Competitive Prize"},
    };
}
