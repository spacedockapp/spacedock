
package com.funnyhatsoftware.spacedock.fleetprint;

import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Align;
import android.graphics.Paint.Style;
import android.graphics.Picture;
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

import com.funnyhatsoftware.spacedock.data.Captain;
import com.funnyhatsoftware.spacedock.data.EquippedShip;
import com.funnyhatsoftware.spacedock.data.EquippedUpgrade;
import com.funnyhatsoftware.spacedock.data.Squad;
import com.funnyhatsoftware.spacedock.data.Upgrade;

import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;

@TargetApi(Build.VERSION_CODES.KITKAT)
public class PrintFleetAdapter extends PrintDocumentAdapter {

    Context context;
    Squad squad;

    public PdfDocument mPdfDocument;
    public int totalpages;
    private int pageHeight;
    private int pageWidth;
    private String name, email, faction, event, date;
    private Boolean omit_totals;

    public PrintFleetAdapter(Context context, Squad aSquad, String aName, String aEmail,
            String aFaction, String aEvent, String aDate, Boolean totals) {
        this.context = context;
        this.squad = aSquad;
        this.name = aName;
        this.email = aEmail;
        this.faction = aFaction;
        this.event = aEvent;
        this.date = aDate;
        this.omit_totals = totals;

        if (squad.getEquippedShips().size() > 4) {
            int ships = squad.getEquippedShips().size() - 4;
            totalpages = (int) Math.ceil(ships / 6.0);
            totalpages++;
        } else
            totalpages = 1;

    }

    @Override
    public void onLayout(PrintAttributes oldAttributes, PrintAttributes newAttributes,
            CancellationSignal cancellationSignal, LayoutResultCallback callback, Bundle extras) {

        mPdfDocument = new PrintedPdfDocument(context, newAttributes);
        pageHeight = (int) (newAttributes.getMediaSize().getHeightMils() / 1000.00 * 72);
        pageWidth = (int) (newAttributes.getMediaSize().getWidthMils() / 1000.00 * 72);

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
                PageInfo newPage = new PageInfo.Builder(pageWidth, pageHeight, i).create();

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

        Paint paint = new Paint();

        pagenumber++; // Make sure page numbers start at 1

        float sBoxW = (float) (pageWidth * 0.435);

        paint.setStrokeWidth(1);
        paint.setColor(Color.BLACK);
        paint.setStyle(Style.STROKE);
        paint.setStrokeWidth(1);
        canvas.drawRect(18, 18, pageWidth - 18, pageHeight - 40, paint);
        paint.setStyle(Style.FILL);

        if (pagenumber > 1) {
            canvas.translate(35, 44);

            if (squad.getEquippedShips().size() >= ((pagenumber * 8) - 8 - 4)) {
                int shipNo = 1;
                for (EquippedShip ship : squad.getEquippedShips()) {
                    if (shipNo <= ((pagenumber * 8) - 8 - 4) || shipNo > ((pagenumber * 8) - 4)) {
                        shipNo++;
                        continue;
                    }
                    canvas.drawPicture(this.drawShip(ship));
                    if ((shipNo & 0x01) != 0) {
                        canvas.save();
                        canvas.translate(pageWidth - 68 - sBoxW, 0);
                    } else {
                        canvas.restore();
                        canvas.translate(0, 168);
                    }

                    shipNo++;
                }
                while (shipNo <= ((pagenumber * 8) - 4)) {
                    canvas.drawPicture(this.drawShip(null));
                    if ((shipNo & 0x01) != 0) {
                        canvas.save();
                        canvas.translate(pageWidth - 68 - sBoxW, 0);
                    } else {
                        canvas.restore();
                        canvas.translate(0, 168);
                    }
                    shipNo++;
                }

            }

            return;
        }

        canvas.drawRect(18, 18, pageWidth - 18, 76, paint);

        paint.setColor(Color.WHITE);
        paint.setTextSize(24);
        paint.setTextAlign(Align.CENTER);

        canvas.drawText("Fleet Build Sheet", pageWidth / 2, 56, paint);

        paint.setColor(Color.BLACK);
        paint.setTextSize(14);
        paint.setTextAlign(Align.RIGHT);
        paint.setTypeface(Typeface.DEFAULT);

        canvas.drawText("Date:", 88, 98, paint);
        canvas.drawText("Event:", 88, 123, paint);
        canvas.drawText("Faction:", 88, 147, paint);

        canvas.drawText("Name:", pageWidth - 18 - 15 - 164 - 9, 98, paint);
        canvas.drawText("Email:", pageWidth - 18 - 15 - 164 - 9, 123, paint);

        paint.setStyle(Style.STROKE);
        canvas.drawRect(97, 82, 97 + 164, 103, paint);
        canvas.drawRect(97, 107, 97 + 164, 128, paint);
        canvas.drawRect(97, 132, 97 + 164, 152, paint);
        canvas.drawRect(pageWidth - 18 - 15 - 164, 82, pageWidth - 34, 103, paint);
        canvas.drawRect(pageWidth - 18 - 15 - 164, 107, pageWidth - 34, 128, paint);

        canvas.drawRect(34, 495, pageWidth - 34, 537, paint);
        canvas.drawRect(138, 546, pageWidth - 120, 569, paint);
        canvas.drawRect(pageWidth - 68, 546, pageWidth - 34, 569, paint);

        paint.setStyle(Style.FILL);

        paint.setColor(Color.BLACK);
        paint.setTextAlign(Align.LEFT);
        canvas.drawText("Resource Used:", 34, 563, paint);
        canvas.drawText("SP", pageWidth - 88, 563, paint);

        paint.setColor(Color.BLACK);
        float tW = (float) (pageWidth - 68) / 7;
        canvas.drawLine(34, 593, pageWidth - 34, 593, paint);
        for (int i = 1; i < 7; i++) {
            canvas.drawLine(34 + tW * i, 577, 34 + tW * i, 613, paint);
        }
        paint.setStyle(Style.STROKE);
        paint.setColor(Color.BLACK);
        canvas.drawRect(34, 577, pageWidth - 34, 613, paint);
        paint.setStyle(Style.FILL);

        paint.setTextSize(10);
        paint.setTextAlign(Align.CENTER);
        canvas.drawText("Ship 1", 34 + ((tW * 1) - (tW / 2)), 589, paint);
        canvas.drawText("Ship 2", 34 + ((tW * 2) - (tW / 2)), 589, paint);
        canvas.drawText("Ship 3", 34 + ((tW * 3) - (tW / 2)), 589, paint);
        canvas.drawText("Ship 4", 34 + ((tW * 4) - (tW / 2)), 589, paint);
        canvas.drawText("Resource", 34 + ((tW * 5) - (tW / 2)), 589, paint);
        canvas.drawText("Other", 34 + ((tW * 6) - (tW / 2)), 589, paint);
        canvas.drawText("Total", 34 + ((tW * 7) - (tW / 2)), 589, paint);

        canvas.save();
        canvas.translate(18, pageHeight - 128 - 40);
        canvas.drawPicture(this.drawBattleFooter());
        canvas.restore();

        paint.setTextSize(10);
        paint.setColor(Color.BLACK);
        paint.setTypeface(Typeface.MONOSPACE);
        paint.setTextAlign(Align.LEFT);

        canvas.drawText(this.date, 101, 97, paint);
        canvas.drawText(this.event, 101, 122, paint);
        canvas.drawText(this.faction, 101, 147, paint);
        canvas.drawText(this.name, pageWidth - 18 - 15 - 160, 97, paint);
        canvas.drawText(this.email, pageWidth - 18 - 15 - 160, 122, paint);

        paint.setTextSize(9);
        paint.setColor(Color.BLACK);
        paint.setTypeface(Typeface.MONOSPACE);
        paint.setTextAlign(Align.LEFT);

        TextPaint notesPaint = new TextPaint();
        StaticLayout notesLayout = new StaticLayout(squad.getNotes(), notesPaint, (pageWidth - 70),
                Alignment.ALIGN_NORMAL, 1.0f, 0.0f, false);
        canvas.save();
        canvas.translate(35, 496);
        notesLayout.draw(canvas);
        canvas.restore();

        int othertotal = squad.getAdditionalPoints();

        ArrayList<EquippedShip> allShips = squad.getEquippedShips();

        if (allShips.size() > 4) {
            for (int i = 4; i < allShips.size(); i++) {
                othertotal += allShips.get(i).calculateCost();
            }
        }

        canvas.save();
        for (int i = 0; i < 4; i++) {
            canvas.restore();
            canvas.save();
            switch (i) {
                case 0:
                    canvas.translate(34, 160);
                    break;
                case 1:
                    canvas.translate(pageWidth - 33 - sBoxW, 160);
                    break;
                case 2:
                    canvas.translate(34, 338);
                    break;
                case 3:
                    canvas.translate(pageWidth - 33 - sBoxW, 338);
                    break;
            }
            if (i < allShips.size()) {
                canvas.drawPicture(this.drawShip(allShips.get(i)));
                canvas.restore();
                canvas.save();
                paint.setTextSize(14);
                paint.setTextAlign(Align.CENTER);
                if (i == 0)
                    canvas.drawText(Integer.toString(allShips.get(i).calculateCost()),
                            34 + ((tW * 1) - (tW / 2)), 608, paint);
                if (i == 1)
                    canvas.drawText(Integer.toString(allShips.get(i).calculateCost()),
                            34 + ((tW * 2) - (tW / 2)), 608, paint);
                if (i == 2)
                    canvas.drawText(Integer.toString(allShips.get(i).calculateCost()),
                            34 + ((tW * 3) - (tW / 2)), 608, paint);
                if (i == 3)
                    canvas.drawText(Integer.toString(allShips.get(i).calculateCost()),
                            34 + ((tW * 4) - (tW / 2)), 608, paint);
            } else {
                canvas.drawPicture(this.drawShip(null));
            }
        }
        canvas.restore();

        if (squad.getResource() != null && !squad.getResource().isPlaceholder()) {
            paint.setTextSize(14);
            paint.setTextAlign(Align.LEFT);

            canvas.drawText(squad.getResource().getTitle(), 139, 562, paint);
            paint.setTextAlign(Align.CENTER);
            if (squad.getResource().getIsFlagship() || squad.getResource().isFleetCaptain()) {
                canvas.drawText("Inc", pageWidth - 51, 562, paint);
                canvas.drawText("Inc", 34 + ((tW * 5) - (tW / 2)), 608, paint);
            } else {
                canvas.drawText(Integer.toString(squad.getResource().getCost()), pageWidth - 51,
                        562, paint);
                canvas.drawText(Integer.toString(squad.getResource().getCost()),
                        34 + ((tW * 5) - (tW / 2)), 608, paint);
            }
        }

        if (!this.omit_totals) {
            if (othertotal > 0)
                canvas.drawText(Integer.toString(othertotal), 34 + ((tW * 6) - (tW / 2)), 608,
                        paint);

            canvas.drawText(Integer.toString(squad.calculateCost()), 34 + ((tW * 7) - (tW / 2)),
                    608, paint);
        }

        paint.setStyle(Style.STROKE);
        paint.setStrokeWidth(1);
        canvas.drawRect(18, 18, pageWidth - 18, pageHeight - 40, paint);
    }

    private Picture drawShip(EquippedShip ship) {
        float width = (float) (pageWidth * 0.435);
        Picture shipBox = new Picture();
        Canvas canvas = shipBox.beginRecording((int) width, 152);
        Paint paint = new Paint();

        paint.setColor(Color.GRAY);
        canvas.drawLine((float) (width * .15), 0, (float) (width * .15), 132, paint);
        canvas.drawLine((float) (width * .70), 0, (float) (width * .70), 132, paint);
        canvas.drawLine((float) (width * .85), 0, (float) (width * .85), 132, paint);
        for (int lineNo = 1; lineNo < 12; lineNo++) {
            canvas.drawLine(0, (lineNo * 11), width, (lineNo * 11), paint);
        }
        paint.setColor(Color.BLACK);
        paint.setStyle(Style.STROKE);
        paint.setStrokeWidth(1);
        canvas.drawRect(0, 0, width, 132, paint);
        canvas.drawRect((float) (width * .85), 132, width, 152, paint);
        paint.setStyle(Style.FILL);

        paint.setTextSize(10);
        paint.setTextAlign(Align.CENTER);
        canvas.drawText("Type", (float) (width * .075), 10, paint);
        canvas.drawText("Card Title", (float) (width * .425), 10, paint);
        canvas.drawText("Faction", (float) (width * .775), 10, paint);
        canvas.drawText("SP", (float) (width * .925), 10, paint);

        if (ship != null) {
            paint.setTextSize(9);
            paint.setTypeface(Typeface.MONOSPACE);
            paint.setTextAlign(Align.LEFT);

            int upgNo = 1;

            paint.setTextAlign(Align.LEFT);
            canvas.drawText("Ship", 0, 10 + (11 * upgNo), paint);
            canvas.drawText(ship.getTitle(), (float) (width * .15), 10 + (11 * upgNo), paint);
            paint.setTextAlign(Align.CENTER);
            canvas.drawText(ship.getFaction().toUpperCase().substring(0, 3),
                    (float) (width * .775), 10 + (11 * upgNo), paint);
            paint.setTextAlign(Align.RIGHT);
            canvas.drawText(Integer.toString(ship.getBaseCost()), (float) (width * .99),
                    10 + (11 * upgNo), paint);
            upgNo++;

            if (ship.getFlagship() != null) {
                paint.setTextAlign(Align.LEFT);
                canvas.drawText("Flag", 0, 10 + (11 * upgNo), paint);
                canvas.drawText(ship.getFlagship().getTitle(), (float) (width * .15),
                        10 + (11 * upgNo), paint);
                paint.setTextAlign(Align.CENTER);
                canvas.drawText(ship.getFlagship().getFaction().toUpperCase().substring(0, 3),
                        (float) (width * .775), 10 + (11 * upgNo), paint);
                paint.setTextAlign(Align.RIGHT);
                canvas.drawText(Integer.toString(ship.getFlagship().getCost()),
                        (float) (width * .99), 10 + (11 * upgNo), paint);
                upgNo++;
            }

            Captain cap = ship.getCaptain();
            paint.setTextAlign(Align.LEFT);
            canvas.drawText("Captain", 0, 10 + (11 * upgNo), paint);
            canvas.drawText(cap.getTitle(), (float) (width * .15), 10 + (11 * upgNo), paint);
            paint.setTextAlign(Align.CENTER);
            canvas.drawText(cap.getFaction().toUpperCase().substring(0, 3), (float) (width * .775),
                    10 + (11 * upgNo), paint);
            paint.setTextAlign(Align.RIGHT);
            canvas.drawText(Integer.toString(cap.getCost()), (float) (width * .99),
                    10 + (11 * upgNo), paint);
            upgNo++;

            if (ship.getFleetCaptain() != null) {
                paint.setTextAlign(Align.LEFT);
                canvas.drawText("FleetCap", 0, 10 + (11 * upgNo), paint);
                canvas.drawText(ship.getFleetCaptain().getTitle(), 0 + (float) (width * .15),
                        10 + (11 * upgNo), paint);
                paint.setTextAlign(Align.CENTER);
                canvas.drawText(ship.getFleetCaptain().getFaction().toUpperCase().substring(0, 3),
                        (float) (width * .775), 10 + (11 * upgNo), paint);
                paint.setTextAlign(Align.RIGHT);
                canvas.drawText(Integer.toString(ship.getFleetCaptain().getCost()),
                        (float) (width * .99), 10 + (11 * upgNo), paint);
                upgNo++;
            }

            for (EquippedUpgrade anUpg : ship.getAllUpgradesExceptPlaceholders()) {
                Upgrade theUpg = anUpg.getUpgrade();
                if (anUpg.isCaptain())
                    continue;
                if (theUpg.isPlaceholder())
                    continue;

                paint.setTextAlign(Align.CENTER);
                if (!theUpg.isTalent())
                    canvas.drawText(theUpg.getUpType().substring(0, 1), (float) (width * .075),
                            10 + (11 * upgNo), paint);
                if (theUpg.isTalent())
                    canvas.drawText("E".substring(0, 1), (float) (width * .075), 10 + (11 * upgNo),
                            paint);
                paint.setTextAlign(Align.LEFT);
                canvas.drawText(theUpg.getTitle(), (float) (width * .15), 10 + (11 * upgNo), paint);
                paint.setTextAlign(Align.CENTER);
                canvas.drawText(theUpg.getFaction().toUpperCase().substring(0, 3),
                        (float) (width * .775), 10 + (11 * upgNo), paint);
                paint.setTextAlign(Align.RIGHT);
                canvas.drawText(Integer.toString(theUpg.getCost()), (float) (width * .99),
                        10 + (11 * upgNo), paint);
                upgNo++;
            }
            paint.setTextSize(14);
            paint.setTextAlign(Align.CENTER);
            canvas.drawText(Integer.toString(ship.calculateCost()), (float) (width * .925), 148,
                    paint);
        }
        shipBox.endRecording();
        return shipBox;
    }

    private Picture drawBattleFooter() {
        Picture battleFooter = new Picture();
        Canvas canvas = battleFooter.beginRecording(pageWidth - 36, 128);
        Paint paint = new Paint();
        float width = (float) (pageWidth * 0.435);

        paint.setColor(Color.GRAY);
        canvas.drawRect(0, 0, canvas.getWidth(), canvas.getHeight(), paint);

        paint.setColor(Color.BLACK);

        paint.setStrokeWidth(1);

        paint.setTextSize(16);
        paint.setTextAlign(Align.CENTER);

        canvas.drawText("Before Battle Starts:", 16 + (width / 2), 20, paint);
        canvas.drawText("After Battle Ends:", canvas.getWidth() - 16 - (width / 2), 20, paint);

        canvas.save();
        canvas.translate(16, 25);
        paint.setColor(Color.WHITE);
        canvas.drawRect(0, 0, width, 82, paint);
        paint.setColor(Color.GRAY);
        canvas.drawLine(0, 34, width, 34, paint);
        canvas.drawLine(0, 50, width, 50, paint);
        canvas.drawLine(0, 66, width, 66, paint);
        canvas.drawLine((float) (width * .15), 0, (float) (width * .15), 82, paint);
        canvas.drawLine((float) (width * .80), 0, (float) (width * .80), 82, paint);
        paint.setStyle(Style.STROKE);
        paint.setColor(Color.BLACK);
        canvas.drawRect(0, 0, width, 82, paint);
        paint.setStyle(Style.FILL);
        paint.setTextSize(10);
        canvas.drawText("1", (float) (width * .075), 46, paint);
        canvas.drawText("2", (float) (width * .075), 62, paint);
        canvas.drawText("3", (float) (width * .075), 78, paint);
        paint.setTextSize(7);
        canvas.drawText("Battle", (float) (width * .075), 15, paint);
        canvas.drawText("Round", (float) (width * .075), 25, paint);
        canvas.drawText("Opponent's Name", (float) ((width * .15) + (width * .325)), 20, paint);
        canvas.drawText("Opponent's", (float) (width * .9), 10, paint);
        canvas.drawText("Initials", (float) (width * .9), 20, paint);
        paint.setTextSize(6);
        canvas.drawText("(Verify Build)", (float) (width * .9), 30, paint);
        canvas.restore();

        canvas.save();
        canvas.translate(canvas.getWidth() - 16 - width, 25);
        paint.setColor(Color.WHITE);
        canvas.drawRect(0, 0, width, 82, paint);
        paint.setColor(Color.GRAY);
        canvas.drawLine(0, 34, width, 34, paint);
        canvas.drawLine(0, 50, width, 50, paint);
        canvas.drawLine(0, 66, width, 66, paint);
        canvas.drawLine((float) (width * .25), 0, (float) (width * .25), 82, paint);
        canvas.drawLine((float) (width * .50), 0, (float) (width * .50), 82, paint);
        canvas.drawLine((float) (width * .75), 0, (float) (width * .75), 82, paint);
        paint.setStyle(Style.STROKE);
        paint.setColor(Color.BLACK);
        canvas.drawRect(0, 0, width, 82, paint);
        paint.setStyle(Style.FILL);
        paint.setTextSize(7);
        canvas.drawText("Your Result", (float) (width * .125), 15, paint);
        canvas.drawText("(W-L-B)", (float) (width * .125), 25, paint);
        canvas.drawText("Your", (float) (width * .375), 15, paint);
        canvas.drawText("Fleet Points", (float) (width * .375), 25, paint);
        canvas.drawText("Cumulative", (float) (width * .625), 15, paint);
        canvas.drawText("Fleet Points", (float) (width * .625), 25, paint);
        canvas.drawText("Cumulative", (float) (width * .875), 10, paint);
        canvas.drawText("Fleet Points", (float) (width * .875), 20, paint);
        paint.setTextSize(6);
        canvas.drawText("(Verify Result)", (float) (width * .875), 30, paint);
        canvas.restore();

        paint.setColor(Color.BLACK);
        paint.setTextSize(10);
        canvas.drawText("Printed by Space Dock Ð www.spacedockapp.org", canvas.getWidth() / 2, 123,
                paint);

        battleFooter.endRecording();
        return battleFooter;
    }

    private boolean pageInRange(PageRange[] pageRanges, int page) {
        for (int i = 0; i < pageRanges.length; i++) {
            if ((page >= pageRanges[i].getStart()) && (page <= pageRanges[i].getEnd()))
                return true;
        }
        return false;
    }
}
