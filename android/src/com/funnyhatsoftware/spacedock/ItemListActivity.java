
package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.Map;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.NavUtils;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Adapter;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;
import android.widget.ListView;

import com.funnyhatsoftware.spacedock.data.Universe;

public abstract class ItemListActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_item_list);

        ListView lv = (ListView) findViewById(R.id.itemList);
        Universe universe = Universe.getUniverse();
        ArrayList<String> factions = universe.getAllFactions();
        final SeparatedListAdapter headerAdapter = new SeparatedListAdapter(this);
        int listRowId = getListRowId();
        for (String s : factions) {
            BaseAdapter adapter = createSectionAdapter(universe, s, listRowId);
            if (adapter.getCount() > 0) {
                headerAdapter.addSection(s, adapter);
            }
        }
        lv.setAdapter(headerAdapter);
        final Activity self = this;
        lv.setOnItemClickListener(new OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                int viewType = headerAdapter.getItemViewType(position);
                if (SeparatedListAdapter.TYPE_SECTION_HEADER != viewType) {
                    handleClickedItem(headerAdapter, self, position);
                }
            }
        });
        getActionBar().setDisplayHomeAsUpEnabled(true);
    }

    protected abstract BaseAdapter createSectionAdapter(Universe universe, String s, int listRowId);

    protected abstract void handleClickedItem(SeparatedListAdapter headerAdapter, Activity self,
            int position);

    protected abstract int getListRowId();

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.captains_list, menu);
        return true;
    }

    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                final Intent intent = NavUtils.getParentActivityIntent(this);
                intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
                NavUtils.navigateUpTo(this, intent);
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public ItemListActivity() {
        super();
    }

    protected static class SeparatedListAdapter extends BaseAdapter
    {
        public final Map<String, Adapter> sections = new LinkedHashMap<String, Adapter>();
        public final ArrayAdapter<String> headers;
        public final static int TYPE_SECTION_HEADER = 0;

        public SeparatedListAdapter(Context context)
        {
            headers = new ArrayAdapter<String>(context, R.layout.list_header);
        }

        public void addSection(String section, Adapter adapter)
        {
            this.headers.add(section);
            this.sections.put(section, adapter);
        }

        public Object getItem(int position)
        {
            for (Object section : this.sections.keySet())
            {
                Adapter adapter = sections.get(section);
                int size = adapter.getCount() + 1;

                // check if position inside this section
                if (position == 0)
                    return section;
                if (position < size)
                    return adapter.getItem(position - 1);

                // otherwise jump into next section
                position -= size;
            }
            return null;
        }

        public int getCount()
        {
            // total together all sections, plus one for each section header
            int total = 0;
            for (Adapter adapter : this.sections.values())
                total += adapter.getCount() + 1;
            return total;
        }

        @Override
        public int getViewTypeCount()
        {
            // assume that headers count as one, then total all sections
            int total = 1;
            for (Adapter adapter : this.sections.values())
                total += adapter.getViewTypeCount();
            return total;
        }

        @Override
        public int getItemViewType(int position)
        {
            int type = 1;
            for (Object section : this.sections.keySet())
            {
                Adapter adapter = sections.get(section);
                int size = adapter.getCount() + 1;

                // check if position inside this section
                if (position == 0)
                    return TYPE_SECTION_HEADER;
                if (position < size)
                    return type + adapter.getItemViewType(position - 1);

                // otherwise jump into next section
                position -= size;
                type += adapter.getViewTypeCount();
            }
            return -1;
        }

        public boolean areAllItemsSelectable()
        {
            return false;
        }

        @Override
        public boolean isEnabled(int position)
        {
            return (getItemViewType(position) != TYPE_SECTION_HEADER);
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent)
        {
            int sectionnum = 0;
            for (Object section : this.sections.keySet())
            {
                Adapter adapter = sections.get(section);
                int size = adapter.getCount() + 1;

                // check if position inside this section
                if (position == 0)
                    return headers.getView(sectionnum, convertView, parent);
                if (position < size)
                    return adapter.getView(position - 1, convertView, parent);

                // otherwise jump into next section
                position -= size;
                sectionnum++;
            }
            return null;
        }

        @Override
        public long getItemId(int position)
        {
            return position;
        }

    }
}
