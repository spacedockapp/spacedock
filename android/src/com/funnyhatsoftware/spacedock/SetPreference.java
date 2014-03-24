package com.funnyhatsoftware.spacedock;

import android.content.Context;
import android.preference.MultiSelectListPreference;
import android.util.AttributeSet;

import com.funnyhatsoftware.spacedock.data.Set;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.ArrayList;
import java.util.HashSet;

public class SetPreference extends MultiSelectListPreference {
    public SetPreference(Context context, AttributeSet attrs) {
        super(context, attrs);

        ArrayList<Set> sets = Universe.getUniverse().getAllSets();
        String[] setLabels = new String[sets.size()];
        String[] setPrefIdLabels = new String[sets.size()];
        java.util.Set<String> defaultValues = new HashSet<String>();

        // TODO: sort sets here (perhaps starter, expansions by date, OPs by date)

        for (int i = 0; i < sets.size(); i++) {
            String preferenceLabel = sets.get(i).getProductName();
            String preferenceId = "pref_use_set_" + preferenceLabel.toLowerCase();
            setLabels[i] = preferenceLabel;
            setPrefIdLabels[i] = preferenceId;
            defaultValues.add(preferenceId); // each set enabled by default
        }
        setEntries(setLabels);
        setEntryValues(setPrefIdLabels);
        setDefaultValue(defaultValues);
    }

    @Override
    protected void onSetInitialValue(boolean restoreValue, Object defaultValue) {
        super.onSetInitialValue(restoreValue, defaultValue);
    }
}
