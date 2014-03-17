package com.funnyhatsoftware.spacedock.holder;

import android.content.Context;
import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.ShipDetailActivity;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Ship;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.List;

public class ShipHolder extends ItemHolder {
    public static final String TYPE_STRING = "Ship";
    static ItemHolderFactory getFactory() {
        return new ItemHolderFactory(TYPE_STRING, R.layout.ship_list_row, 0) {
            @Override
            public ItemHolder createHolder(View view) {
                return new ShipHolder(view);
            }

            @Override
            public List<?> getItemsForFaction(String faction) {
                return Universe.getUniverse().getShipsForFaction(faction);
            }
        };
    }

    final TextView mTitle;
    final TextView mCost;

    private ShipHolder(View view) {
        mTitle = (TextView) view.findViewById(R.id.shipRowTitle);
        mCost = (TextView) view.findViewById(R.id.shipRowCost);
    }

    @Override
    public void reinitialize(Resources res, Object item) {
        Ship ship = (Ship) item;
        mTitle.setText(ship.getTitle());
        mCost.setText(Integer.toString(ship.getCost()));
    }

    @Override
    public void navigateToDetails(Context context, Object item) {
        navigateToDetailsActivity(context, (SetItem)item, ShipDetailActivity.class);
    }
}
