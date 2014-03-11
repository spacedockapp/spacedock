
package com.funnyhatsoftware.spacedock;

import java.util.List;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.data.Flagship;

public class FlagshipsAdapter extends ItemAdapter<Flagship> {

    public FlagshipsAdapter(Context context, int resource, List<Flagship> objects) {
        super(context, resource, objects);
    }

    protected void setupView(int position, View convertView) {
        Flagship fs = (Flagship) getItem(position);
        TextView title = (TextView) convertView.findViewById(R.id.flagshipRowTitle);
        title.setText(fs.getTitle());
        setupValueField(convertView, fs, R.id.flagshipRowAttack, fs.getAttack());
        setupValueField(convertView, fs, R.id.flagshipRowAgility, fs.getAgility());
        setupValueField(convertView, fs, R.id.flagshipRowHull, fs.getHull());
        setupValueField(convertView, fs, R.id.flagshipRowShield, fs.getShield());
    }

    protected void setupValueField(View convertView, Flagship fs, int resourceId, int value) {
        TextView attack = (TextView) convertView.findViewById(resourceId);
        if (value > 0) {
            attack.setText(Integer.toString(value));
            attack.setVisibility(View.VISIBLE);
        } else {
            attack.setText("");
            attack.setVisibility(View.INVISIBLE);
        }
    }

}
