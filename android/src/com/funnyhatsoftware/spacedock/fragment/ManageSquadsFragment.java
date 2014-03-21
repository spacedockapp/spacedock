package com.funnyhatsoftware.spacedock.fragment;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.text.InputType;
import android.text.Spannable;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.funnyhatsoftware.spacedock.activity.EditSquadActivity;
import com.funnyhatsoftware.spacedock.FactionInfo;
import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.Squad;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.ArrayList;
import java.util.HashSet;

public class ManageSquadsFragment extends ListFragment {
    private static final String SAVE_KEY_SELECTED_SQUAD = "selected_squad";

    public interface SquadSelectListener {
        public void onSquadSelected(int squadIndex);
        public void onSquadEditAction(int squadIndex);
    }

    SquadAdapter mAdapter;
    int mSquadIndex = -1;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);

        // setup adapter
        final Context context = getActivity();
        ArrayList<Squad> squads = new ArrayList<Squad>(Universe.getUniverse().squads);
        mAdapter = new SquadAdapter(context, squads);
        setListAdapter(mAdapter);

        if (savedInstanceState != null) {
            mSquadIndex = savedInstanceState.getInt(SAVE_KEY_SELECTED_SQUAD);
        }
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        boolean isTwoPane = true; // TODO
        getListView().setChoiceMode(isTwoPane
                ? ListView.CHOICE_MODE_SINGLE
                : ListView.CHOICE_MODE_NONE);
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putInt(SAVE_KEY_SELECTED_SQUAD, mSquadIndex);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        inflater.inflate(R.menu.menu_manage, menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        final int itemId = item.getItemId();
        final Context context = getActivity();

        if (itemId == R.id.menu_create) {
            getCreateName();
        } else if (itemId == R.id.menu_edit) {
            ((SquadSelectListener)getActivity()).onSquadEditAction(mSquadIndex);
        } else if (itemId == R.id.menu_share) {
            Toast.makeText(context, "TODO: sharing.", Toast.LENGTH_SHORT).show();
        }
        return true;
    }

    private boolean tryCreateEmptySquad(String name) {
        if (name == null || name.isEmpty()) return false;

        Squad squad = new Squad();
        squad.setName(name);
        Universe.getUniverse().squads.add(squad);
        mAdapter.add(squad);
        return true;
    }

    private void getCreateName() {
        final Context context = getActivity();
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle(R.string.dialog_request_squad_name);
        final EditText input = new EditText(context);
        input.setInputType(InputType.TYPE_CLASS_TEXT);
        builder.setView(input);

        builder.setPositiveButton(R.string.dialog_accept, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                String squadName = input.getText().toString();
                if (!tryCreateEmptySquad(squadName)) {
                    Toast.makeText(context, "Failed to create squad",
                            Toast.LENGTH_SHORT).show();
                }
            }
        });
        builder.setNegativeButton(R.string.dialog_reject, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        });
        builder.show();
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);
        mSquadIndex = position;
        ((SquadSelectListener)getActivity()).onSquadSelected(mSquadIndex);
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
