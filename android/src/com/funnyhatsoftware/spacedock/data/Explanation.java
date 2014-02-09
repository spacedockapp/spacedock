
package com.funnyhatsoftware.spacedock.data;

public class Explanation {
    public Explanation(boolean b) {
        canAdd = b;
    }

    public Explanation(boolean b, String inResult, String inExplanation) {
        canAdd = b;
        result = inResult;
        explanation = inExplanation;
    }

    public static final Explanation SUCCESS = new Explanation(true);
    
    public boolean canAdd;
    public String result;
    public String explanation;
}
