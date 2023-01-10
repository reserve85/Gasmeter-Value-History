unit uGraph;

interface

uses
  Generics.Collections,
  DateUtils,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VclTee.TeEngine,
  VclTee.Series, Data.DB, VclTee.TeeData, Vcl.ExtCtrls, VclTee.TeeProcs,
  VclTee.Chart, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TGasValue = class(TComponent)
  private
    { private declarations }
    FDate: TDateTime;
    FDay: Word;
    FMonth: Word;
    FYear: Word;
    FValueInQM: Double;
    FValueInKwh: Double;
  public
    { public declarations }
    constructor Create(AOwner: TComponent); override;
    property Date: TDateTime read FDate;
    property Day: Word read FDay;
    property Month: Word read FMonth;
    property Year: Word read FYear;
    property ValueInQM: Double read FValueInQM;
    property ValueInKwh: Double read FValueInKwh;
    procedure AddValue(const pDate: TDateTime; const pValueInQm, pCalorificValue, pZValue: Double);
  end;

type
  TGraph = class(TForm)
    chtOverall: TChart;
    lnsrsOverall: TLineSeries;
    pnlOverall: TPanel;
    pnlDailyOverall: TPanel;
    pnlYearly: TPanel;
    pnlYear: TPanel;
    btnPreviousYear: TButton;
    btnNextYear: TButton;
    lblActiveYear: TLabel;
    chtDailyOverall: TChart;
    lnsrsDailyOverall: TLineSeries;
    chtYearly: TChart;
    brsrsYearly: TBarSeries;
    pnlStatistics: TPanel;
    redtStatistics: TRichEdit;
    procedure chtOverallMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure chtDailyOverallMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FillMonthlyChart(const pYear: Word);
    procedure btnPreviousYearClick(Sender: TObject);
    procedure btnNextYearClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    mValueList: TObjectList<TGasValue>;
    FZValue: Double;
    FCalorificValue: Double;
    function DaysInYear(const pYear: Word): Word;
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddValue(const pData: TDateTime; const pValueInQm: Double);
    property ZValue: Double read FZValue write FZValue;
    property CalorificValue: Double read FCalorificValue write FCalorificValue;
  end;

implementation

{$R *.dfm}
{ TForm1 }

procedure TGraph.AddValue(const pData: TDateTime; const pValueInQm: Double);
var
  lclGasValue: TGasValue;
begin
  lclGasValue := TGasValue.Create(self);
  lclGasValue.AddValue(pData, pValueInQm, CalorificValue, ZValue);
  mValueList.Add(lclGasValue);
end;

procedure TGraph.btnNextYearClick(Sender: TObject);
begin
  // Fill Monthly Chart
  brsrsYearly.ValuesList.Clear;
  lblActiveYear.Caption := (strtoint(lblActiveYear.Caption) + 1).ToString;
  FillMonthlyChart(strtoint(lblActiveYear.Caption));
end;

procedure TGraph.btnPreviousYearClick(Sender: TObject);
begin
  // Fill Monthly Chart
  brsrsYearly.ValuesList.Clear;
  lblActiveYear.Caption := (strtoint(lblActiveYear.Caption) - 1).ToString;
  FillMonthlyChart(strtoint(lblActiveYear.Caption));
end;

procedure TGraph.chtDailyOverallMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lclIndex: Integer;
begin
  lclIndex := lnsrsDailyOverall.GetCursorValueIndex;
  if lclIndex <> -1 then
  begin
    chtDailyOverall.Hint := lnsrsDailyOverall.YValue[lclIndex].ToString + ' kWh';
    chtDailyOverall.ShowHint := true;
  end
  else
  begin
    chtDailyOverall.Hint := '';
    chtDailyOverall.ShowHint := false;
  end;
end;

procedure TGraph.chtOverallMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lclIndex: Integer;
begin
  lclIndex := lnsrsOverall.GetCursorValueIndex;
  if lclIndex <> -1 then
  begin
    chtOverall.Hint := lnsrsOverall.YValue[lclIndex].ToString + ' m³';
    chtOverall.ShowHint := true;
  end
  else
  begin
    chtOverall.Hint := '';
    chtOverall.ShowHint := false;
  end;
end;

constructor TGraph.Create(AOwner: TComponent);
var
  i: Integer;
begin
  inherited;
  FZValue := 0;
  FCalorificValue := 0;
  mValueList := TObjectList<TGasValue>.Create(true);
  for i := 1 to 12 do
  begin
    brsrsYearly.Add(0, '', clTeeColor);
  end;
end;

destructor TGraph.Destroy;
begin
  FreeAndNil(mValueList);
  inherited;
end;

function TGraph.DaysInYear(const pYear: Word): Word;
begin
  Result := 365;
  if (pYear mod 4 = 0) and ((pYear mod 100 <> 0) or (pYear mod 400 = 0)) then
    Inc(Result);
end;

procedure TGraph.FillMonthlyChart(const pYear: Word);
var
  i: Integer;
  lclSumKwh: Double;
  lclFirstFound: boolean;
  lclFirstDay, lclLastDay: TDateTime;
begin
  lclSumKwh := 0;
  lclFirstDay := now;
  lclLastDay := now;
  lclFirstFound := false;
  redtStatistics.Clear;

  FreeAndNil(brsrsYearly);
  brsrsYearly := TBarSeries.Create(self);
  chtYearly.AddSeries(brsrsYearly);

  for i := 0 to 11 do
  begin
    brsrsYearly.Add(0, '', clTeeColor);
    brsrsYearly.YValue[i] := 0;
  end;

  for i := 1 to mValueList.Count - 1 do
  begin
    if mValueList.Items[i].Year <> pYear then
      continue;

    if not lclFirstFound then
    begin
      lclFirstDay := mValueList.Items[i].Date;
      lclFirstFound := true;
    end;
    lclLastDay := mValueList.Items[i].Date;

    brsrsYearly.YValue[mValueList.Items[i].Month - 1] := brsrsYearly.YValue[mValueList.Items[i].Month - 1] + (mValueList.Items[i].ValueInKwh - mValueList.Items[i - 1].ValueInKwh);
    lclSumKwh := lclSumKwh + mValueList.Items[i].ValueInKwh - mValueList.Items[i - 1].ValueInKwh;
  end;

  try
    redtStatistics.Lines.Add('Actual sum ' + IntToStr(pYear) + ': ' + FloatToStr(lclSumKwh) + 'kWh');
    redtStatistics.Lines.Add('Forecast ' + IntToStr(pYear) + ': ' + FloatToStr(lclSumKwh / (DaysBetween(lclFirstDay, lclLastDay) + 1) * DaysInYear(pYear)) + 'kWh');
  except
    redtStatistics.Clear;
  end;
end;

procedure TGraph.FormResize(Sender: TObject);
begin
  pnlOverall.Height := Round(1 / 3 * ClientHeight);
  pnlDailyOverall.Height := Round(1 / 3 * ClientHeight);
  pnlYearly.Height := Round(1 / 3 * ClientHeight);
end;

procedure TGraph.FormShow(Sender: TObject);
var
  i: Integer;
  lclGasValue: TGasValue;
begin
  // fill Overall Chart
  for lclGasValue in mValueList do
  begin
    lnsrsOverall.AddXY(lclGasValue.Date, lclGasValue.ValueInQM);
  end;

  // fill Daily Chart
  for i := 1 to mValueList.Count - 1 do
  begin
    lnsrsDailyOverall.AddXY(mValueList.Items[i].Date, mValueList.Items[i].ValueInKwh - mValueList.Items[i - 1].ValueInKwh);
  end;

  // Fill Monthly Chart
  lblActiveYear.Caption := YearOf(now).ToString;
  FillMonthlyChart(YearOf(now));
end;

{ TGasValue }

procedure TGasValue.AddValue(const pDate: TDateTime; const pValueInQm, pCalorificValue, pZValue: Double);
begin
  FValueInQM := pValueInQm;
  FValueInKwh := pValueInQm * pCalorificValue * pZValue;
  FDate := pDate;
  DecodeDate(pDate, FYear, FMonth, FDay);
end;

constructor TGasValue.Create(AOwner: TComponent);
begin
  inherited;
  FDate := 0;
  FDay := 0;
  FMonth := 0;
  FYear := 0;
  FValueInQM := 0;
  FValueInKwh := 0;
end;

end.
