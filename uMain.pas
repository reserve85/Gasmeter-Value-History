﻿unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.IOUtils, System.IniFiles,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, IdStream, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP, System.DateUtils, Generics.Collections, Generics.Defaults, Vcl.ComCtrls;

type
  TGasmeter = class(TForm)
    lbledtURL: TLabeledEdit;
    btnDownloadLogfiles: TButton;
    lbledtMaxLogfilesOnServer: TLabeledEdit;
    lbledtTargetDirectory: TLabeledEdit;
    idhtp1: TIdHTTP;
    lbledtCsvFile: TLabeledEdit;
    redtLog: TRichEdit;
    lblImpressum: TLabel;
    procedure btnDownloadLogfilesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    mINI: TINIFile;
    function DownloadFile(pURL: string; pDestFileName: string): boolean;
    function LoadValue(const pFileName: string): Extended;
    procedure LoadCSV(const pFileName: string);
    procedure SaveCSV(const pFileName: string);
    procedure LoadINI;
    procedure WriteINI;
  public
    { Public declarations }
  end;

var
  Gasmeter: TGasmeter;

implementation

{$R *.dfm}

procedure TGasmeter.btnDownloadLogfilesClick(Sender: TObject);
var
  lclDateString: string;
  lclFilenameCsv: string;
  lclFilenameTxtOld: string;
  i: Integer;
  lclValue: Extended;
begin
  redtLog.Clear;
  try
    LoadCSV(lbledtCsvFile.Text);
  except
    on E:Exception do
    begin
      ShowMessage('Error load CSV: ' + E.Message);
    end;
  end;  
  
  for i := StrToInt(lbledtMaxLogfilesOnServer.Text) downto 1 do
  begin
    DateTimeToString(lclDateString, 'yyyy-mm-dd', incDay(Now, - i));
    lclFilenameCsv := 'data_' + lclDateString + '.csv'; // http://192.168.10.65/fileserver/log/data/data_2022-11-28.csv
    lclFilenameTxtOld := 'log_' + lclDateString + '.txt'; // http://192.168.10.65/fileserver/log/message/log_2022-11-10.txt
    if (redtLog.FindText(lclDateString, 0, Length(redtLog.Lines.Text), [stWholeWord]) = -1) then
    begin
      if DownloadFile(lbledtURL.Text + 'data/' + lclFilenameCsv, lbledtTargetDirectory.Text + lclFilenameCsv) then
      begin
        lclValue := LoadValue(lbledtTargetDirectory.Text + lclFilenameCsv);
        redtLog.Lines.Add(lclDateString + ';' + FloatToStrF(lclValue, ffFixed, 8, 2));
      end
      else if DownloadFile(lbledtURL.Text + 'message/' + lclFilenameTxtOld, lbledtTargetDirectory.Text + lclFilenameTxtOld) then
      begin
        lclValue := LoadValue(lbledtTargetDirectory.Text + lclFilenameTxtOld);
        redtLog.Lines.Add(lclDateString + ';' + FloatToStrF(lclValue, ffFixed, 8, 2));
      end;
    end;
  end;
  
  try
    SaveCSV(lbledtCsvFile.Text);
  except
    on E:Exception do
    begin
      ShowMessage('Error write CSV: ' + E.Message);
    end;
  end;
end;

procedure TGasmeter.LoadCSV(const pFileName: string);
var
  Txt: TextFile;
  s: string;
begin
  if FileExists(pFileName) then
  begin
    AssignFile(Txt, pFileName);
    Reset(Txt);
    while not Eof(Txt) do
    begin
      try
        Readln(Txt, s);
        redtLog.Lines.Add(s);
      except
        continue;
      end;
    end;
    CloseFile(Txt);
  end
  else
  begin
    redtLog.Lines.Add('Date;Value');
  end;
end;

procedure TGasmeter.LoadINI;
begin
  lbledtURL.Text := mINI.ReadString('MAIN', 'URL', 'http://192.168.10.65/fileserver/log/message/');
  lbledtMaxLogfilesOnServer.Text := mINI.ReadString('MAIN', 'CountLogfiles', '30');
  lbledtTargetDirectory.Text := mINI.ReadString('MAIN', 'Log', 'C:\Temp\Gas\');
  lbledtCsvFile.Text := mINI.ReadString('MAIN', 'CsvFile', 'C:\Temp\Gas\Values.csv');
end;

function TGasmeter.LoadValue(const pFileName: string): Extended;
var
  Txt: TextFile;
  s: string;
  lclStringList: TStringList;
  lclStartPos: Integer;
  lclEndPos: Integer;
begin
  Result := 0;
  lclStringList := TStringList.Create;
  try
    AssignFile(Txt, pFileName);
    Reset(Txt);
    while not Eof(Txt) do
    begin
      Readln(Txt, s);
      if ExtractFileExt(pFileName) = '.csv' then
      begin
        if (AnsiPos('no error', s) <> 0) then
        begin
          lclStringList.Clear;
          lclStringList.Delimiter := ';';
          s := StringReplace(s, ',', ';', [rfReplaceAll, rfIgnoreCase]);
          s := StringReplace(s, '.', ',', [rfReplaceAll, rfIgnoreCase]);
          lclStringList.DelimitedText := s;
          try
            Result := lclStringList[3].ToExtended;
          except
            Continue;
          end;
        end;
      end
      else
      begin
        if (AnsiPos('Value: ', s) <> 0) and (AnsiPos(' Error: no error', s) <> 0) then
        begin
          lclStartPos := AnsiPos('Value: ', s) + 7;
          lclEndPos := AnsiPos(' Error: no error', s) - lclStartPos;
          s := StringReplace(s, '.', ',', [rfReplaceAll, rfIgnoreCase]);
          try
            Result := StrToFloat(Copy(s, lclStartPos, lclEndPos));
          except
            continue;
          end;
        end;
      end;
    end;
  finally
    CloseFile(Txt);
    FreeAndNil(lclStringList);
  end;
end;

procedure TGasmeter.SaveCSV(const pFileName: string);
begin
  TFile.WriteAllText(pFileName, redtLog.Lines.Text);
end;

procedure TGasmeter.WriteINI;
begin
  mINI.WriteString('MAIN', 'URL', lbledtURL.Text);
  mINI.WriteString('MAIN', 'CountLogfiles', lbledtMaxLogfilesOnServer.Text);
  mINI.WriteString('MAIN', 'Log', lbledtTargetDirectory.Text);
  mINI.WriteString('MAIN', 'CsvFile', lbledtCsvFile.Text);
end;

function TGasmeter.DownloadFile(pURL: string; pDestFileName: string): boolean;
var
  Http: TIdHTTP;
  FS: TFileStream;
begin
  Result := true;
  ForceDirectories(ExtractFileDir(pDestFileName));
  FS := TFileStream.Create(pDestFileName, fmCreate);
  try
    try
      Http := TIdHTTP.Create(nil);
      try
        Http.Get(pURL, FS);
      finally
        Http.Free;
      end;
    finally
      FS.Free;
    end;
  except
    DeleteFile(pDestFileName);
    Exit(false);
  end;
end;

procedure TGasmeter.FormCreate(Sender: TObject);
begin
  mINI := TINIFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  LoadINI;
  redtLog.Clear;
  lblImpressum.Caption := 'reserve, 2022' + #13#10 + 'free to copy and modify'
end;

procedure TGasmeter.FormDestroy(Sender: TObject);
begin
  WriteINI;
  FreeAndNil(mINI);
end;

end.
