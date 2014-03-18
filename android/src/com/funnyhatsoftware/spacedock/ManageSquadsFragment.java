package com.funnyhatsoftware.spacedock;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.text.InputType;
import android.text.Spannable;
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

import com.funnyhatsoftware.spacedock.data.Squad;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.ArrayList;
import java.util.HashSet;

public class ManageSquadsFragment extends ListFragment {
    private static ArrayList<SquadWrapper> sSquads = new ArrayList<SquadWrapper>();

    private ArrayList<SquadWrapper> getSquads() {
        if (sSquads.isEmpty()) {
            for (Squad s : Universe.getUniverse().squads) {
                sSquads.add(new SquadWrapper(s));
                sSquads.add(new SquadWrapper(s)); // duplicate for testing
            }
        }
        return sSquads;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);

        // setup adapter
        final Context context = getActivity();
        setListAdapter(new SquadAdapter(context, getSquads()));
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
            Intent intent = new Intent(context, EditSquadActivity.class);
            startActivity(intent);
        } else if (itemId == R.id.menu_share) {
            Toast.makeText(context, "TODO: sharing.", Toast.LENGTH_SHORT).show();
        }
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
                Toast.makeText(context, "success", Toast.LENGTH_SHORT).show();
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

    private static class SquadWrapper {
        Squad squad;
        SquadWrapper(Squad squad) {
            this.squad = squad;
        }

        @Override
        public String toString() {
            return squad.getName();
        }
    }

    private static class SquadAdapter extends ArrayAdapter<SquadWrapper> {
        final HashSet<String> mHashSet = new HashSet<String>();
        public SquadAdapter(Context context, ArrayList<SquadWrapper> squads) {
            super(context, R.layout.squad_summary, R.id.title, squads);
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            View listItem = super.getView(position, convertView, parent);
            Squad squad = getItem(position).squad;

            mHashSet.clear();
            squad.getFactions(mHashSet);
            Spannable factionSummary = FactionInfo.buildSummarySpannable(
                    parent.getResources(), mHashSet);
            ((TextView) listItem.findViewById(R.id.faction_summary)).setText(factionSummary);

            String costString = Integer.toString(squad.calculateCost());
            ((TextView) listItem.findViewById(R.id.cost)).setText(costString);

            return listItem;
        }
    }
}
