program Gasmeter_Value_History;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Gasmeter},
  uGraph in 'uGraph.pas' {Graph};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := DebugHook = 1;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGasmeter, Gasmeter);
  Application.Run;
end.
