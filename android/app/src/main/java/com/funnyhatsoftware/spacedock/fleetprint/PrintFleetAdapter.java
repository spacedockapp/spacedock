
package com.funnyhatsoftware.spacedock.fleetprint;

import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Align;
import android.graphics.Paint.Style;
import android.graphics.Typeface;
import android.graphics.pdf.PdfDocument;
import android.graphics.pdf.PdfDocument.PageInfo;
import android.os.Build;
import android.os.Bundle;
import android.os.CancellationSignal;
import android.os.ParcelFileDescriptor;
import android.print.PageRange;
import android.print.PrintAttributes;
import android.print.PrintDocumentAdapter;
import android.print.PrintDocumentInfo;
import android.print.pdf.PrintedPdfDocument;
import android.text.Layout.Alignment;
import android.text.StaticLayout;
import android.text.TextPaint;

import com.funnyhatsoftware.spacedock.data.Admiral;
import com.funnyhatsoftware.spacedock.data.Captain;
import com.funnyhatsoftware.spacedock.data.EquippedShip;
import com.funnyhatsoftware.spacedock.data.EquippedUpgrade;
import com.funnyhatsoftware.spacedock.data.Flagship;
import com.funnyhatsoftware.spacedock.data.FleetCaptain;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Ship;
import com.funnyhatsoftware.spacedock.data.Squad;
import com.funnyhatsoftware.spacedock.data.Upgrade;

import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;

@TargetApi(Build.VERSION_CODES.KITKAT)
public class PrintFleetAdapter extends PrintDocumentAdapter {

    Context context;

    public PdfDocument mPdfDocument;
    public int totalpages;
    private int mPageHeight;
    private int mPageWidth;
    private String mName, mEmail, mFaction, mEvent, mDate;
    private Boolean mOmit_totals;
    private Squad mSquad;
    private Paint mStrokePaint, mLinePaint, mBlackPaint, mWhitePaint, mDataPaint;
    private float mBoxWidth, tW;
    
    public PrintFleetAdapter(Context context, Squad squad, String name, String email,
            String faction, String event, String date, Boolean totals) {
        this.context = context;
        mSquad = squad;
        mName = name;
        mEmail = email;
        mFaction = faction;
        mEvent = event;
        mDate = date;
        mOmit_totals = totals;
        
        mStrokePaint = new Paint();
        mStrokePaint.setStyle(Style.STROKE);
        mStrokePaint.setStrokeWidth(1);
        mStrokePaint.setColor(Color.BLACK);
        
        mLinePaint = new Paint();
        mLinePaint.setColor(Color.GRAY);

        mBlackPaint = new Paint();
        mBlackPaint.setColor(Color.BLACK);
        mBlackPaint.setTypeface(Typeface.SANS_SERIF);

        mWhitePaint = new Paint();
        mWhitePaint.setColor(Color.WHITE);
        mWhitePaint.setTypeface(Typeface.SANS_SERIF);
        
        mDataPaint = new Paint();
        mDataPaint.setColor(Color.BLACK);
        mDataPaint.setTypeface(Typeface.MONOSPACE);
        mDataPaint.setTextAlign(Align.LEFT);


        if (squad.getEquippedShips().size() > 4) {
            int ships = squad.getEquippedShips().size() - 4;
            totalpages = (int) Math.ceil(ships / 6.0);
            totalpages++;
        } else {
            totalpages = 1;
        }
    }

    @Override
    public void onLayout(PrintAttributes oldAttributes, PrintAttributes newAttributes,
            CancellationSignal cancellationSignal, LayoutResultCallback callback, Bundle extras) {

        mPdfDocument = new PrintedPdfDocument(context, newAttributes);
        mPageHeight = (int) (newAttributes.getMediaSize().getHeightMils() / 1000.00 * 72);
        mPageWidth = (int) (newAttributes.getMediaSize().getWidthMils() / 1000.00 * 72);

        mBoxWidth = (float) (mPageWidth * 0.435);
        tW = (float) (mPageWidth - 68) / 7;
        
        if (cancellationSignal.isCanceled()) {
            callback.onLayoutCancelled();
            return;
        }

        if (totalpages > 0) {
            PrintDocumentInfo.Builder builder = new PrintDocumentInfo.Builder("fleet_build.pdf")
                    .setContentType(PrintDocumentInfo.CONTENT_TYPE_DOCUMENT).setPageCount(
                            totalpages);

            PrintDocumentInfo info = builder.build();
            callback.onLayoutFinished(info, true);
        } else {
            callback.onLayoutFailed("Page count is zero.");
        }
    }

    @Override
    public void onWrite(PageRange[] pages, ParcelFileDescriptor destination,
            CancellationSignal cancellationSignal, WriteResultCallback callback) {

        for (int i = 0; i < totalpages; i++) {
            if (pageInRange(pages, i)) {
                PageInfo newPage = new PageInfo.Builder(mPageWidth, mPageHeight, i).create();

                PdfDocument.Page page = mPdfDocument.startPage(newPage);

                if (cancellationSignal.isCanceled()) {
                    callback.onWriteCancelled();
                    mPdfDocument.close();
                    mPdfDocument = null;
                    return;
                }
                drawPage(page, i);
                mPdfDocument.finishPage(page);
            }
        }

        try {
            mPdfDocument.writeTo(new FileOutputStream(destination.getFileDescriptor()));
        } catch (IOException e) {
            callback.onWriteFailed(e.toString());
            return;
        } finally {
            mPdfDocument.close();
            mPdfDocument = null;
        }

        callback.onWriteFinished(pages);

    }

    private void drawPage(PdfDocument.Page page, int pagenumber) {
        Canvas canvas = page.getCanvas();

        pagenumber++; // Make sure page numbers start at 1
        
        if (pagenumber > 1) {
            ArrayList<EquippedShip> ships = getShipsForPage(pagenumber);
            for (int i = 0; i < 8; i++) {
                canvas.save();
                EquippedShip ship = i < ships.size() ? ships.get(i) : null;
                if ((i & 0x01) == 0) {
                    canvas.translate(34, (float) (44 + ((int)Math.floor(i/2) * 168)));
                } else {
                    canvas.translate(mPageWidth - 34 - mBoxWidth, (float) (44 + ((int)Math.floor(i/2) * 168)));
                }
                drawShip(ship,canvas);
                canvas.restore();
            }
            canvas.drawRect(18, 18, mPageWidth - 18, mPageHeight - 40, mStrokePaint);

            return;
        }


        drawPageHeader(canvas);
        drawNotes(canvas);
        drawResource(canvas);
        drawTotalsBox(canvas);
        drawBattleFooter(canvas);

        int othertotal = mSquad.getAdditionalPoints();

        ArrayList<EquippedShip> allShips = mSquad.getEquippedShips();

        if (allShips.size() > 4) {
            for (int i = 4; i < allShips.size(); i++) {
                othertotal += allShips.get(i).calculateCost();
            }
        }

        for (int i = 0; i < 4; i++) {
            canvas.save();
            switch (i) {
                case 0:
                    canvas.translate(34, 160);
                    break;
                case 1:
                    canvas.translate(mPageWidth - 34 - mBoxWidth, 160);
                    break;
                case 2:
                    canvas.translate(34, 328);
                    break;
                case 3:
                    canvas.translate(mPageWidth - 34 - mBoxWidth, 328);
                    break;
            }
            if (i < allShips.size()) {
                drawShip(allShips.get(i),canvas);
                mDataPaint.setTextSize(14);
                mDataPaint.setTextAlign(Align.CENTER);
                canvas.restore();
                if (i == 0)
                    canvas.drawText(Integer.toString(allShips.get(i).calculateCost()),
                            34 + ((tW * 1) - (tW / 2)), 608, mDataPaint);
                if (i == 1)
                    canvas.drawText(Integer.toString(allShips.get(i).calculateCost()),
                            34 + ((tW * 2) - (tW / 2)), 608, mDataPaint);
                if (i == 2)
                    canvas.drawText(Integer.toString(allShips.get(i).calculateCost()),
                            34 + ((tW * 3) - (tW / 2)), 608, mDataPaint);
                if (i == 3)
                    canvas.drawText(Integer.toString(allShips.get(i).calculateCost()),
                            34 + ((tW * 4) - (tW / 2)), 608, mDataPaint);
            } else {
                drawShip(null,canvas);
                canvas.restore();
            }
        }

        if (!mOmit_totals) {
            if (othertotal > 0)
                canvas.drawText(Integer.toString(othertotal), 34 + ((tW * 6) - (tW / 2)), 608,
                        mDataPaint);

            canvas.drawText(Integer.toString(mSquad.calculateCost()), 34 + ((tW * 7) - (tW / 2)),
                    608, mDataPaint);
        }
        
        canvas.drawRect(18, 18, mPageWidth - 18, mPageHeight - 40, mStrokePaint);
    }

    private void drawPageHeader( Canvas canvas ) {
        canvas.drawRect(18, 18, mPageWidth - 18, 76, mBlackPaint);

        mWhitePaint.setTextSize(24);
        mWhitePaint.setTextAlign(Align.CENTER);

        canvas.drawText("Fleet Build Sheet", mPageWidth / 2, 56, mWhitePaint);

        mBlackPaint.setTextSize(14);
        mBlackPaint.setTextAlign(Align.RIGHT);

        canvas.drawText("Date:", 88, 98, mBlackPaint);
        canvas.drawText("Event:", 88, 123, mBlackPaint);
        canvas.drawText("Faction:", 88, 147, mBlackPaint);

        canvas.drawText("Name:", mPageWidth - 18 - 15 - 164 - 9, 98, mBlackPaint);
        canvas.drawText("Email:", mPageWidth - 18 - 15 - 164 - 9, 123, mBlackPaint);

        canvas.drawRect(97, 82, 97 + 164, 103, mStrokePaint);
        canvas.drawRect(97, 107, 97 + 164, 128, mStrokePaint);
        canvas.drawRect(97, 132, 97 + 164, 152, mStrokePaint);
        canvas.drawRect(mPageWidth - 18 - 15 - 164, 82, mPageWidth - 34, 103, mStrokePaint);
        canvas.drawRect(mPageWidth - 18 - 15 - 164, 107, mPageWidth - 34, 128, mStrokePaint);
        
        mDataPaint.setTextSize(10);
        mDataPaint.setTextAlign(Align.LEFT);
        canvas.drawText(mDate, 101, 97, mDataPaint);
        canvas.drawText(mEvent, 101, 122, mDataPaint);
        canvas.drawText(mFaction, 101, 147, mDataPaint);
        canvas.drawText(mName, mPageWidth - 18 - 15 - 160, 97, mDataPaint);
        canvas.drawText(mEmail, mPageWidth - 18 - 15 - 160, 122, mDataPaint);
    }
    
    private void drawNotes(Canvas canvas) {
        canvas.drawRect(34, 495, mPageWidth - 34, 537, mStrokePaint);
        canvas.drawRect(138, 546, mPageWidth - 120, 569, mStrokePaint);
        canvas.drawRect(mPageWidth - 68, 546, mPageWidth - 34, 569, mStrokePaint);
        
        TextPaint notesPaint = new TextPaint();
        StaticLayout notesLayout = new StaticLayout(mSquad.getNotes(), notesPaint, (mPageWidth - 70),
                Alignment.ALIGN_NORMAL, 1.0f, 0.0f, false);
        canvas.save();
        canvas.translate(35, 496);
        notesLayout.draw(canvas);
        canvas.restore();
    }
    
    private void drawResource(Canvas canvas) {
        mBlackPaint.setTextSize(14);
        mBlackPaint.setTextAlign(Align.LEFT);
        canvas.drawText("Resource Used:", 34, 563, mBlackPaint);
        canvas.drawText("SP", mPageWidth - 88, 563, mBlackPaint);

        if (mSquad.getResource() != null && !mSquad.getResource().isPlaceholder()) {
            mDataPaint.setTextSize(14);
            mDataPaint.setTextAlign(Align.LEFT);

            canvas.drawText(mSquad.getResource().getTitle(), 139, 562, mDataPaint);
            mDataPaint.setTextAlign(Align.CENTER);
            if (mSquad.getResource().getIsFlagship() || mSquad.getResource().isFleetCaptain()) {
                canvas.drawText("Inc", mPageWidth - 51, 562, mDataPaint);
                canvas.drawText("Inc", 34 + ((tW * 5) - (tW / 2)), 608, mDataPaint);
            } else {
                canvas.drawText(Integer.toString(mSquad.getResource().getCostForSquad(mSquad)), mPageWidth - 51,
                        562, mDataPaint);
                canvas.drawText(Integer.toString(mSquad.getResource().getCostForSquad(mSquad)),
                        34 + ((tW * 5) - (tW / 2)), 608, mDataPaint);
            }
        }
    }
    
    private void drawTotalsBox(Canvas canvas) {
        canvas.drawLine(34, 593, mPageWidth - 34, 593, mBlackPaint);
        for (int i = 1; i < 7; i++) {
            canvas.drawLine(34 + tW * i, 577, 34 + tW * i, 613, mBlackPaint);
        }

        canvas.drawRect(34, 577, mPageWidth - 34, 613, mStrokePaint);

        mBlackPaint.setTextSize(10);
        mBlackPaint.setTextAlign(Align.CENTER);
        canvas.drawText("Ship 1", 34 + ((tW * 1) - (tW / 2)), 589, mBlackPaint);
        canvas.drawText("Ship 2", 34 + ((tW * 2) - (tW / 2)), 589, mBlackPaint);
        canvas.drawText("Ship 3", 34 + ((tW * 3) - (tW / 2)), 589, mBlackPaint);
        canvas.drawText("Ship 4", 34 + ((tW * 4) - (tW / 2)), 589, mBlackPaint);
        canvas.drawText("Resource", 34 + ((tW * 5) - (tW / 2)), 589, mBlackPaint);
        canvas.drawText("Other", 34 + ((tW * 6) - (tW / 2)), 589, mBlackPaint);
        canvas.drawText("Total", 34 + ((tW * 7) - (tW / 2)), 589, mBlackPaint);
        
    }
    
    private void drawShip(EquippedShip ship, Canvas canvas) {
        canvas.save();
        
        canvas.drawLine((float) (mBoxWidth * .15), 0, (float) (mBoxWidth * .15), 132, mLinePaint);
        canvas.drawLine((float) (mBoxWidth * .70), 0, (float) (mBoxWidth * .70), 132, mLinePaint);
        canvas.drawLine((float) (mBoxWidth * .85), 0, (float) (mBoxWidth * .85), 132, mLinePaint);
        for (int lineNo = 1; lineNo < 12; lineNo++) {
            canvas.drawLine(0, (lineNo * 11), mBoxWidth, (lineNo * 11), mLinePaint);
        }
        canvas.drawRect(0, 0, mBoxWidth, 132, mStrokePaint);
        canvas.drawRect((float) (mBoxWidth * .85), 132, mBoxWidth, 152, mStrokePaint);

        mBlackPaint.setTextSize(10);
        mBlackPaint.setTextAlign(Align.CENTER);
        canvas.drawText("Type", (float) (mBoxWidth * .075), 10, mBlackPaint);
        canvas.drawText("Card Title", (float) (mBoxWidth * .425), 10, mBlackPaint);
        canvas.drawText("Faction", (float) (mBoxWidth * .775), 10, mBlackPaint);
        canvas.drawText("SP", (float) (mBoxWidth * .925), 10, mBlackPaint);

        if (ship != null) {
            mDataPaint.setTextSize(9);
            mDataPaint.setTextAlign(Align.LEFT);
            canvas.save();
            canvas.translate(0, 11);
            drawShipItem(ship.getShip(),ship.getBaseCost(),canvas);
            
            if (ship.getFlagship() != null && !ship.getFlagship().isPlaceholder()) {
                canvas.translate(0, 11);
                drawShipItem(ship.getFlagship(),ship.getFlagship().getCost(),canvas);

            }

            canvas.translate(0, 11);
            drawShipItem(ship.getCaptain(),ship.getEquippedCaptain().calculateCost(),canvas);

            if (ship.getFleetCaptain() != null && !ship.getFleetCaptain().isPlaceholder()) {
                canvas.translate(0, 11);
                drawShipItem(ship.getFleetCaptain(),ship.getFleetCaptain().getCost(),canvas);
            }

            for (EquippedUpgrade anUpg : ship.getAllUpgradesExceptPlaceholders()) {
                Upgrade theUpg = anUpg.getUpgrade();
                if (anUpg.isCaptain()) {
                    continue;
                } else if (theUpg.isPlaceholder()) {
                    continue;
                }

                canvas.translate(0, 11);
                
                drawShipItem(theUpg,anUpg.calculateCost(),canvas);
            }
            canvas.restore();
            mDataPaint.setTextSize(14);
            mDataPaint.setTextAlign(Align.CENTER);
            canvas.drawText(Integer.toString(ship.calculateCost()), (float) (mBoxWidth * .925), 148,
                    mDataPaint);
        }

        canvas.restore();
    }

    
    private void drawShipItem(SetItem shipItem, int calcCost, Canvas canvas)
    {
        String upgradeCode = new String();
        mDataPaint.setTextAlign(Align.CENTER);

        if ( shipItem instanceof Ship ) {
            upgradeCode = "Ship";
        } else if ( shipItem instanceof Flagship ) {
            upgradeCode = "Flagship";
        } else if ( shipItem instanceof FleetCaptain ) {
            upgradeCode = "FleetCap";
        } else if ( shipItem instanceof Admiral ) {
            upgradeCode = "Admiral";
        } else if ( shipItem instanceof Captain ) {
            upgradeCode = "Captain";
        } else if ( shipItem instanceof Upgrade) {
            Upgrade upgrade = (Upgrade)shipItem;
            if (upgrade.isTalent()) {
                upgradeCode = "E";
            } else {
                upgradeCode = upgrade.getUpType().substring(0, 1);
            }
        }

        canvas.drawText(upgradeCode, (float) (mBoxWidth * .075),
                10, mDataPaint);
        mDataPaint.setTextAlign(Align.LEFT);
        canvas.drawText(shipItem.getTitle(), (float) (mBoxWidth * .15), 10, mDataPaint);
        mDataPaint.setTextAlign(Align.CENTER);
        canvas.drawText(shipItem.getFaction().toUpperCase().substring(0, 3),
                (float) (mBoxWidth * .775), 10, mDataPaint);
        mDataPaint.setTextAlign(Align.RIGHT);
        canvas.drawText(Integer.toString(calcCost), (float) (mBoxWidth * .99),
                10, mDataPaint);
    }
    
    private void drawBattleFooter(Canvas canvas) {
        canvas.save();
        canvas.translate(18, mPageHeight - 128 - 40);
        
        canvas.drawRect(0, 0, mPageWidth - 36, 128, mLinePaint);


        mBlackPaint.setTextSize(16);
        mBlackPaint.setTextAlign(Align.CENTER);

        canvas.drawText("Before Battle Starts:", 16 + (mBoxWidth / 2), 20, mBlackPaint);
        canvas.drawText("After Battle Ends:", mPageWidth - 52 - (mBoxWidth / 2), 20, mBlackPaint);

        canvas.save();
        canvas.translate(16, 25);
        canvas.drawRect(0, 0, mBoxWidth, 82, mWhitePaint);
        canvas.drawLine(0, 34, mBoxWidth, 34, mLinePaint);
        canvas.drawLine(0, 50, mBoxWidth, 50, mLinePaint);
        canvas.drawLine(0, 66, mBoxWidth, 66, mLinePaint);
        canvas.drawLine((float) (mBoxWidth * .15), 0, (float) (mBoxWidth * .15), 82, mLinePaint);
        canvas.drawLine((float) (mBoxWidth * .80), 0, (float) (mBoxWidth * .80), 82, mLinePaint);
        canvas.drawRect(0, 0, mBoxWidth, 82, mStrokePaint);
        mBlackPaint.setTextSize(10);
        canvas.drawText("1", (float) (mBoxWidth * .075), 46, mBlackPaint);
        canvas.drawText("2", (float) (mBoxWidth * .075), 62, mBlackPaint);
        canvas.drawText("3", (float) (mBoxWidth * .075), 78, mBlackPaint);
        mBlackPaint.setTextSize(7);
        canvas.drawText("Battle", (float) (mBoxWidth * .075), 15, mBlackPaint);
        canvas.drawText("Round", (float) (mBoxWidth * .075), 25, mBlackPaint);
        canvas.drawText("Opponent's Name", (float) ((mBoxWidth * .15) + (mBoxWidth * .325)), 20, mBlackPaint);
        canvas.drawText("Opponent's", (float) (mBoxWidth * .9), 10, mBlackPaint);
        canvas.drawText("Initials", (float) (mBoxWidth * .9), 20, mBlackPaint);
        mBlackPaint.setTextSize(6);
        canvas.drawText("(Verify Build)", (float) (mBoxWidth * .9), 30, mBlackPaint);
        canvas.restore();

        canvas.save();
        canvas.translate(mPageWidth - 52 - mBoxWidth, 25);
        canvas.drawRect(0, 0, mBoxWidth, 82, mWhitePaint);
        canvas.drawLine(0, 34, mBoxWidth, 34, mLinePaint);
        canvas.drawLine(0, 50, mBoxWidth, 50, mLinePaint);
        canvas.drawLine(0, 66, mBoxWidth, 66, mLinePaint);
        canvas.drawLine((float) (mBoxWidth * .25), 0, (float) (mBoxWidth * .25), 82, mLinePaint);
        canvas.drawLine((float) (mBoxWidth * .50), 0, (float) (mBoxWidth * .50), 82, mLinePaint);
        canvas.drawLine((float) (mBoxWidth * .75), 0, (float) (mBoxWidth * .75), 82, mLinePaint);
        canvas.drawRect(0, 0, mBoxWidth, 82, mStrokePaint);
        mBlackPaint.setTextSize(7);
        canvas.drawText("Your Result", (float) (mBoxWidth * .125), 15, mBlackPaint);
        canvas.drawText("(W-L-B)", (float) (mBoxWidth * .125), 25, mBlackPaint);
        canvas.drawText("Your", (float) (mBoxWidth * .375), 15, mBlackPaint);
        canvas.drawText("Fleet Points", (float) (mBoxWidth * .375), 25, mBlackPaint);
        canvas.drawText("Cumulative", (float) (mBoxWidth * .625), 15, mBlackPaint);
        canvas.drawText("Fleet Points", (float) (mBoxWidth * .625), 25, mBlackPaint);
        canvas.drawText("Cumulative", (float) (mBoxWidth * .875), 10, mBlackPaint);
        canvas.drawText("Fleet Points", (float) (mBoxWidth * .875), 20, mBlackPaint);
        mBlackPaint.setTextSize(6);
        canvas.drawText("(Verify Result)", (float) (mBoxWidth * .875), 30, mBlackPaint);
        canvas.restore();        


        canvas.restore();
        mBlackPaint.setTextSize(10);
        mBlackPaint.setTextAlign(Align.CENTER);
        canvas.drawText("Printed by Space Dock www.spacedockapp.org", mPageWidth / 2, mPageHeight - 45,
                mBlackPaint);
    }

    private ArrayList<EquippedShip> getShipsForPage(int pagenumber)
    {
        ArrayList<EquippedShip> shipsForPage = new ArrayList<EquippedShip>();
        int shipNo = 1;
        for (EquippedShip ship : mSquad.getEquippedShips()) {
            if ( pagenumber == 1 && shipNo <= 4 ) {
                shipsForPage.add(ship);
            } else if ( shipNo > ((pagenumber * 8) - 8 - 4) && shipNo <= ((pagenumber * 8) - 4) ) {
                shipsForPage.add(ship);
            }
            shipNo ++;
        }
        return shipsForPage;
    }
    
    private boolean pageInRange(PageRange[] pageRanges, int page) {
        for (int i = 0; i < pageRanges.length; i++) {
            if ((page >= pageRanges[i].getStart()) && (page <= pageRanges[i].getEnd()))
                return true;
        }
        return false;
    }
}
