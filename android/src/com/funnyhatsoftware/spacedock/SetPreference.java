package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;

import android.content.Context;
import android.preference.MultiSelectListPreference;
import android.util.AttributeSet;

import com.funnyhatsoftware.spacedock.data.Set;
import com.funnyhatsoftware.spacedock.data.Universe;

public class SetPreference extends MultiSelectListPreference {
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
    }

    @Override
    protected void onSetInitialValue(boolean restoreValue, Object defaultValue) {
        super.onSetInitialValue(restoreValue, defaultValue);
    }
}
