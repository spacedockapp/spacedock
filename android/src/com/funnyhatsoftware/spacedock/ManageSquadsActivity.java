package com.funnyhatsoftware.spacedock;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
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

import org.json.JSONException;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashSet;

public class ManageSquadsActivity extends Activity {
    private static ArrayList<SquadWrapper> sSquads = new ArrayList<SquadWrapper>();

    private ArrayList<SquadWrapper> getSquads() {
        if (sSquads.isEmpty()) {
            Squad squad = new Squad();
            try {
                InputStream is = getAssets().open("romulan_2_ship.spacedock");
                squad.importFromStream(Universe.getUniverse(), is);
            } catch (IOException e) {
                e.printStackTrace();
            } catch (JSONException e) {
                e.printStackTrace();
            }
            sSquads.add(new SquadWrapper(squad));
            sSquads.add(new SquadWrapper(squad/*.duplicate()*/));
        }
        return sSquads;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_manage_squads_twopane); // TODO: phone

        ListView listView = (ListView) findViewById(R.id.squad_list);

        // setup adapter
        boolean isTwoPane = findViewById(R.id.right_fragment_container) != null;
        listView.setChoiceMode(isTwoPane
                ? ListView.CHOICE_MODE_SINGLE
                : ListView.CHOICE_MODE_NONE);
        listView.setAdapter(new SquadAdapter(this, getSquads()));
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_manage, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        final int itemId = item.getItemId();

        if (itemId == R.id.menu_create) {
            getCreateName();
        } else if (itemId == R.id.menu_edit) {
            Intent intent = new Intent(this, SquadBuildActivity.class);
            startActivity(intent);
        } else if (itemId == R.id.menu_share) {
            Toast.makeText(this, "TODO: sharing.", Toast.LENGTH_SHORT).show();
        }
        return true;
    }

    private void getCreateName() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(R.string.dialog_request_squad_name);
        final EditText input = new EditText(this);
        input.setInputType(InputType.TYPE_CLASS_TEXT);
        builder.setView(input);

        final Context context = this;
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
