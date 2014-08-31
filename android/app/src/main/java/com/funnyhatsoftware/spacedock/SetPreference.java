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
}
