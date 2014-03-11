
package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;
import java.util.List;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.NavUtils;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.data.Universe;

public abstract class DetailActivity extends Activity {

    protected static class Pair {
            String label;
            String value;
    
            Pair(String inLabel, String inValue) {
                label = inLabel;
                value = inValue;
            }
    
            Pair(String inLabel, int inValue) {
                label = inLabel;
                value = Integer.toString(inValue);
            }
    
            Pair(String inLabel, boolean inValue) {
                label = inLabel;
                value = inValue ? "Yes" : "No";
            }
    
            public String toString() {
                return label + ": " + value;
            }
        }

    protected ArrayList<Pair> mValues = new ArrayList<Pair>();

    protected static class DetailAdapter extends ArrayAdapter<Pair> {
            private int layoutResourceId;
    
            public DetailAdapter(Context context, int resource, List<Pair> objects) {
                super(context, resource, objects);
                layoutResourceId = resource;
            }
    
            public View getView(int position, View convertView, ViewGroup parent) {
                if (convertView == null) {
                    Context context = getContext();
                    LayoutInflater inflater = ((Activity) context).getLayoutInflater();
                    convertView = inflater.inflate(layoutResourceId, parent, false);
                }
                Pair item = getItem(position);
                TextView label = (TextView) convertView.findViewById(R.id.detailLabel);
                label.setText(item.label);
                TextView value = (TextView) convertView.findViewById(R.id.detailValue);
                value.setText(item.value);
                return convertView;
            }
        }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_detail);
        Universe universe = Universe.getUniverse();
        String captainId = getIntent().getStringExtra("externalId");
        String title = setupValues(universe, captainId);
    
        ArrayAdapter<Pair> adapter = new DetailAdapter(this,
                R.layout.detail_row, mValues);
    
        ListView detailList = (ListView) findViewById(R.id.itemDetails);
        detailList.setAdapter(adapter);
    
        // Show the Up button in the action bar.
        setupActionBar(title);
    }

    protected abstract String setupValues(Universe universe, String itemId);

    /**
     * Set up the {@link android.app.ActionBar}.
     */
    private void setupActionBar(String title) {
        ActionBar actionBar = getActionBar();
        actionBar.setDisplayHomeAsUpEnabled(true);
        actionBar.setTitle(title);
    
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.captain_detail, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                // This ID represents the Home or Up button. In the case of this
                // activity, the Up button is shown. Use NavUtils to allow users
                // to navigate up one level in the application structure. For
                // more details, see the Navigation pattern on Android Design:
                //
                // http://developer.android.com/design/patterns/navigation.html#up-vs-back
                //
                NavUtils.navigateUpFromSameTask(this);
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public DetailActivity() {
        super();
    }

}
