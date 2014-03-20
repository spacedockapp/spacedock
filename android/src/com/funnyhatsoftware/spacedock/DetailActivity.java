
package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;
import java.util.List;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.NavUtils;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.holder.ItemHolderFactory;

public class DetailActivity extends Activity {
    public static final String EXTRA_ITEM_TYPE = "itemtype";
    public static final String EXTRA_ITEM_ID = "id";

    public static class DetailDataBuilder {
        private final ArrayList<Pair> mValues = new ArrayList<Pair>();

        public DetailDataBuilder addString(String label, String value) {
            mValues.add(new Pair(label, value));
            return this;
        }

        public DetailDataBuilder addInt(String label, int value) {
            return addString(label, Integer.toString(value));
        }

        public DetailDataBuilder addBoolean(String label, boolean value) {
            return addString(label, value ? "Yes" : "No");
        }

        private ArrayList<Pair> getValues() { return mValues; }
    }

    private static class Pair {
        String label;
        String value;

        private Pair(String inLabel, String inValue) {
            label = inLabel;
            value = inValue;
        }
    }

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
        String itemType = getIntent().getStringExtra(EXTRA_ITEM_TYPE);
        String itemId = getIntent().getStringExtra(EXTRA_ITEM_ID);
        ItemHolderFactory factory = ItemHolderFactory.getHolderFactory(itemType);

        DetailDataBuilder builder = new DetailDataBuilder();
        String title = factory.getDetails(builder, itemId);

        ArrayAdapter<Pair> adapter = new DetailAdapter(this,
                R.layout.detail_row, builder.getValues());

        ListView detailList = (ListView) findViewById(R.id.itemDetails);
        detailList.setAdapter(adapter);

        // Show the Up button in the action bar.
        setupActionBar(title);
    }

    /**
     * Set up the {@link android.app.ActionBar}.
     */
    private void setupActionBar(String title) {
        ActionBar actionBar = getActionBar();
        actionBar.setDisplayHomeAsUpEnabled(true);
        actionBar.setTitle(title);

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
