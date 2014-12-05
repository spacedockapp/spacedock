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
import java.util.List;

public class SetPreference extends MultiSelectListPreference
        implements Preference.OnPreferenceChangeListener {

    public static final String PREF_KEY_SET_ID = "pref_key_set_id_selection";
    public static final String PREF_KEY_SEEN_SET_ID = "pref_key_set_id_seen";

    java.util.Set<String> mObservedSetIds = new HashSet<String>();

    public SetPreference(Context context, AttributeSet attrs) {
        super(context, attrs);

        List<Set> sets = Universe.getUniverse().getAllSets();

        List<String> setLabels = new ArrayList<String>();
        List<String> setValues = new ArrayList<String>();
//        setLabels.add("Select All");
//        setValues.add("ALL");
//        setLabels.add("Select None");
//        setValues.add("NONE");
        Collections.sort(sets, new Set.SetComparator());
        for (Set set : sets){
            setLabels.add(set.getProductName());
            setValues.add(set.getExternalId());
            mObservedSetIds.add(set.getExternalId());
        }
        setEntries(setLabels.toArray(new String[setLabels.size()]));
        setEntryValues(setValues.toArray(new String[setValues.size()]));
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
