program rtfreportsample;

uses
  Vcl.Forms,
  MainFormU in 'MainFormU.pas' {MainForm},
  RTFReportEngine in '..\RTFReportEngine.pas',
  RandomTextUtilsU in 'RandomTextUtilsU.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
