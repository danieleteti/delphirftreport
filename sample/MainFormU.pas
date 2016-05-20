unit MainFormU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Data.DB, Vcl.ExtCtrls, Vcl.FileCtrl, Vcl.ComCtrls, Vcl.Grids,
  Vcl.DBGrids, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TMainForm = class(TForm)
    ds1: TFDMemTable;
    ds1name: TStringField;
    FileListBox1: TFileListBox;
    Panel1: TPanel;
    Button1: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    reReport: TRichEdit;
    reOutput: TRichEdit;
    chkOpenGeneratedFile: TCheckBox;
    ds2: TFDMemTable;
    ds1id: TIntegerField;
    ds2id: TIntegerField;
    ds2contact: TStringField;
    ds2contact_type: TStringField;
    ds2id_person: TIntegerField;
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    TabSheet3: TTabSheet;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    ds1country: TStringField;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FileListBox1DblClick(Sender: TObject);
    procedure FileListBox1Change(Sender: TObject);
  private
    function ReadReport(const FileName: String): String;
    procedure GenerateReport(const aReport: String);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}


uses System.IOUtils, Winapi.Shellapi, RTFReportEngine, RandomTextUtilsU;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  GenerateReport(FileListBox1.FileName);
end;

procedure TMainForm.FileListBox1Change(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 1;
  if tfile.Exists(FileListBox1.FileName) then
    reReport.Lines.LoadFromFile(FileListBox1.FileName);
end;

procedure TMainForm.FileListBox1DblClick(Sender: TObject);
begin
  GenerateReport(FileListBox1.FileName);
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  I: Integer;
  J: Integer;
  lName: string;
  lLastName: string;
begin
  ds1.Open;
  ds2.Open;

  for I := 1 to 10 do
  begin
    lName := GetRndFirstName;
    lLastName := getrndlastname;
    ds1.AppendRecord([I, lName + ' ' + lLastName, GetRndCountry]);
    for J := 1 to Random(4) + 1 do
    begin
      ds2.AppendRecord([I * 100 + J, I, Format('%s.%s@%s.com', [lName.Substring(0, 1).ToLower,
        lLastName.ToLower, GetRndCountry.ToLower]), 'email']);
    end;
  end;
  ds1.First;
  ds2.First;

  // Button2Click(self);
end;

procedure TMainForm.GenerateReport(const aReport: String);
var
  lRTFEngine: TRTFReportEngine;
  lRTFDocument: string;
  lOutputFileName: string;
begin
  reReport.Lines.LoadFromFile(aReport);
  ds1.First;
  lRTFDocument := ReadReport(aReport);

  lRTFEngine := TRTFReportEngine.Create;
  try
    lRTFEngine.SetVar('first_name', 'Daniele');
    lRTFEngine.SetVar('last_name', 'Teti');
    lRTFEngine.SetVar('today', DateToStr(date));
    lRTFEngine.Parse(lRTFDocument, [ds1, ds2]);
    TDirectory.CreateDirectory(ExtractFilePath(Application.ExeName) + 'output');
    lOutputFileName := ExtractFilePath(Application.ExeName) + 'output\' +
      TPath.GetFileNameWithoutExtension(aReport)
      + '_output.rtf';
    tfile.WriteAllText(lOutputFileName, lRTFEngine.GetOutput);
  finally
    lRTFEngine.Free;
  end;
  reOutput.Lines.LoadFromFile(lOutputFileName);
  if chkOpenGeneratedFile.Checked then
    ShellExecute(0, pchar('open'), pchar(lOutputFileName), nil, nil, SW_NORMAL);
  PageControl1.ActivePageIndex := 0;
end;

function TMainForm.ReadReport(const FileName: String): String;
begin
  with TStreamReader.Create(TFileStream.Create(FileName, fmOpenRead, fmShareDenyNone),
    TEncoding.ANSI) do
  begin
    OwnStream;
    Result := ReadToEnd;
    Free;
  end;
end;

end.
