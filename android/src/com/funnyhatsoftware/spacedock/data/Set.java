package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;

public class Set extends SetBase {

	public void addToSet(SetItem item) {
		ArrayList<Set> otherSets = item.getSets();
		for (Set otherSet : otherSets) {
			otherSet.remove(item);
		}
		items.add(item);
	}

	public void remove(SetItem item) {
		items.remove(item);
	}
}
