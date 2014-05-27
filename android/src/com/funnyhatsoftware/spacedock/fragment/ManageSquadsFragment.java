package com.funnyhatsoftware.spacedock.fragment;

import java.util.ArrayList;
import java.util.HashSet;

import org.json.JSONArray;
import org.json.JSONException;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.Spannable;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.FactionInfo;
import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.TextEntryDialog;
import com.funnyhatsoftware.spacedock.data.Squad;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.ArrayList;
import java.util.HashSet;

public class ManageSquadsFragment extends FullscreenListFragment {
    private static final String SAVE_KEY_SELECTED_SQUAD = "selected_squad";

    public interface SquadSelectListener {
        public void onSquadSelected(String squadUuid);
    }

    SquadAdapter mAdapter;
    String mSquadUuid = null;
    SquadSelectListener mSelectListener;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);

        mSelectListener = (SquadSelectListener) getActivity();
        if (mSelectListener == null) throw new IllegalStateException();

        // setup adapter
        final Context context = getActivity();
        ArrayList<Squad> squads = Universe.getUniverse().getAllSquads();
        mAdapter = new SquadAdapter(context, squads);
        setListAdapter(mAdapter);

        if (savedInstanceState != null) {
            mSquadUuid = savedInstanceState.getString(SAVE_KEY_SELECTED_SQUAD);
        }
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        getListView().setChoiceMode(getResources().getBoolean(R.bool.use_two_pane)
                ? ListView.CHOICE_MODE_SINGLE
                : ListView.CHOICE_MODE_NONE);
    }

    @Override
    public void onResume() {
        super.onResume();

        // notify adapter, since squad content may have changed since last display
        mAdapter.notifyDataSetChanged();
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putString(SAVE_KEY_SELECTED_SQUAD, mSquadUuid);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        inflater.inflate(R.menu.menu_manage_squads, menu);
    }

    private void shareAllSquads() {
        try {
            Intent sendIntent = new Intent();
            sendIntent.setAction(Intent.ACTION_SEND);
            JSONArray allSquadsAsJSON = Universe.getUniverse().allSquadsAsJSON();
            sendIntent.putExtra(Intent.EXTRA_TEXT, allSquadsAsJSON.toString(2));
            String fullName = getActivity().getString(R.string.all_squads_spacedocksquads);
            sendIntent.putExtra(android.content.Intent.EXTRA_SUBJECT, fullName);
            sendIntent.setType("application/spacedocksquads");
            startActivity(Intent.createChooser(sendIntent, getActivity().getString(R.string.save_all_squads_to)));
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        final int itemId = item.getItemId();

        if (itemId == R.id.menu_create) {
            startCreateSquad();
            return true;
        }
        if (itemId == R.id.menu_share_all_squads) {
            shareAllSquads();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private void tryCreateEmptySquad(String name) {
        Squad squad = new Squad();
        squad.setName(name);
        Universe.getUniverse().addSquad(squad);
        mAdapter.notifyDataSetChanged();
    }

    private void startCreateSquad() {
        final Context context = getActivity();
        TextEntryDialog.create(context, null,
                R.string.dialog_request_squad_name,
                R.string.dialog_error_empty_squad_name,
                new TextEntryDialog.OnAcceptListener() {
                    @Override
                    public void onTextValueCommitted(String inputText) {
                        tryCreateEmptySquad(inputText);
                    }
                }
        );
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);
        Squad squad = Universe.getUniverse().getSquadByIndex(position);
        mSquadUuid = squad.getUuid();
        mSelectListener.onSquadSelected(mSquadUuid);
    }

    private class SquadAdapter extends ArrayAdapter<Squad> {
        private static final int LAYOUT_RES_ID = R.layout.squad_summary;
        final HashSet<String> mHashSet = new HashSet<String>();
        public SquadAdapter(Context context, ArrayList<Squad> squads) {
            super(context, LAYOUT_RES_ID, squads);
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            if (convertView == null) {
                LayoutInflater inflater = getActivity().getLayoutInflater();
                convertView = inflater.inflate(LAYOUT_RES_ID, parent, false);
            }
            Squad squad = getItem(position);

            ((TextView) convertView.findViewById(R.id.title)).setText(squad.getName());

            mHashSet.clear();
            squad.getFactions(mHashSet);
            Spannable factionSummary = FactionInfo.buildSummarySpannable(
                    parent.getResources(), mHashSet);
            ((TextView) convertView.findViewById(R.id.faction_summary)).setText(factionSummary);

            String costString = Integer.toString(squad.calculateCost());
            ((TextView) convertView.findViewById(R.id.cost)).setText(costString);

            return convertView;
        }
    }
}
