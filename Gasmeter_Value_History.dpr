program Gasmeter_Value_History;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Gasmeter};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGasmeter, Gasmeter);
  Application.Run;
end.
