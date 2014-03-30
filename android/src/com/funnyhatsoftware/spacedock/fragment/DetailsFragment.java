
package com.funnyhatsoftware.spacedock.fragment;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.holder.SetItemHolderFactory;

public class DetailsFragment extends DialogFragment {
    private static final String ARG_ITEM_TYPE = "item_type";
    private static final String ARG_ITEM_ID = "id";

    public static DetailsFragment newInstance(String itemType, String itemId) {
        Bundle args = new Bundle();
        args.putString(ARG_ITEM_TYPE, itemType);
        args.putString(ARG_ITEM_ID, itemId);
        DetailsFragment fragment = new DetailsFragment();
        fragment.setArguments(args);
        return fragment;
    }

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

    protected class DetailAdapter extends ArrayAdapter<Pair> {
        private static final int LAYOUT_RES_ID = R.layout.detail_row;

        public DetailAdapter(Context context, List<Pair> objects) {
            super(context, LAYOUT_RES_ID, objects);
        }

        @Override
        public boolean isEnabled(int position) { return false; }

        public View getView(int position, View convertView, ViewGroup parent) {
            if (convertView == null) {
                LayoutInflater inflater = getActivity().getLayoutInflater();
                convertView = inflater.inflate(LAYOUT_RES_ID, parent, false);
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
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(android.R.layout.list_content, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        String itemType = getArguments().getString(ARG_ITEM_TYPE);
        String itemId = getArguments().getString(ARG_ITEM_ID);
        SetItemHolderFactory factory = SetItemHolderFactory.getHolderFactory(itemType);

        DetailDataBuilder builder = new DetailDataBuilder();
        String title = factory.getDetails(builder, itemId);
        if (getDialog() != null) {
            getDialog().setTitle(title);
        } else {
            // TODO: single pane title
        }

        ArrayAdapter<Pair> adapter = new DetailAdapter(getActivity(), builder.getValues());

        ListView detailList = (ListView) view.findViewById(android.R.id.list);
        detailList.setAdapter(adapter);
    }
}
