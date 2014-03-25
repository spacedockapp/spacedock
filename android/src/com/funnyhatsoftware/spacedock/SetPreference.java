package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;

import android.content.Context;
import android.preference.MultiSelectListPreference;
import android.preference.Preference;
import android.util.AttributeSet;
import android.widget.Toast;

import com.funnyhatsoftware.spacedock.data.Set;
import com.funnyhatsoftware.spacedock.data.Universe;

public class SetPreference extends MultiSelectListPreference
        implements Preference.OnPreferenceChangeListener {
    public SetPreference(Context context, AttributeSet attrs) {
        super(context, attrs);

        ArrayList<Set> sets = Universe.getUniverse().getAllSets();
        String[] setLabels = new String[sets.size()];
        java.util.Set<String> defaultValues = new HashSet<String>();

        Collections.sort(sets, new Set.SetComparator());

        for (int i = 0; i < sets.size(); i++) {
            String preferenceLabel = sets.get(i).getProductName();
            setLabels[i] = preferenceLabel;
            defaultValues.add(preferenceLabel); // each set enabled by default
        }
        setEntries(setLabels);
        setEntryValues(setLabels);
        setDefaultValue(defaultValues);
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
        return true; // approve update, and allow it to be persisted
    }
}
