
package com.funnyhatsoftware.spacedock.fragment;

import java.util.ArrayList;

import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.Universe;

public class ChooseFactionDialog extends DialogFragment {
    public interface FactionChoiceListener {
        /** @param faction Faction chosen, or null if all factions. */
        public void onFactionChoiceUpdated(String faction);
    }
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_faction_list, container);
        getDialog().setTitle(R.string.faction);
        ArrayList<String> factions = new ArrayList<String>();
        factions.addAll(Universe.getUniverse().getAllFactions());
        factions.add(0, getActivity().getString(R.string.all_factions));
        ArrayAdapter<String> arrayAdapter = new ArrayAdapter<String>(this.getActivity(),
                android.R.layout.simple_list_item_1, android.R.id.text1, factions);
        ListView lv = (ListView) view.findViewById(R.id.faction_list);
        lv.setAdapter(arrayAdapter);
        final ChooseFactionDialog dialog = this;
        OnItemClickListener listener = new OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                String faction = null;
                if (position > 0) {
                    ArrayList<String> allFactions = Universe.getUniverse().getAllFactions();
                    faction = allFactions.get(position - 1);
                }
                ((FactionChoiceListener) getActivity()).onFactionChoiceUpdated(faction);
                dialog.dismiss();
            }
        };
        lv.setOnItemClickListener(listener);
        return view;
    }

}
