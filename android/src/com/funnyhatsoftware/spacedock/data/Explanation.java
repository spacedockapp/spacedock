
package com.funnyhatsoftware.spacedock.data;

public class Explanation {
    private Explanation() {
        canAdd = true;
        result = null;
        explanation = null;
    }

    public Explanation(String inResult, String inExplanation) {
        canAdd = false;
        result = inResult;
        explanation = inExplanation;
    }

    public static final Explanation SUCCESS = new Explanation();

    public final boolean canAdd;
    public final String result;
    public final String explanation;
}
