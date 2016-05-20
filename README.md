# RTF Reporting for Delphi (RRD for short)
RRD is Delphi reporting engine based on RTF template.

## Usage guide
```delphi
procedure TMainForm.GenerateReport(const aReport: String);
var
  lRTFEngine: TRTFReportEngine;
  lRTFDocument: string;
  lOutputFileName: string;
begin
  lRTFDocument := TFile.ReadAllText(aReport);

  lRTFEngine := TRTFReportEngine.Create;
  try
		//setting some report variables
    lRTFEngine.SetVar('first_name', 'Daniele');
    lRTFEngine.SetVar('last_name', 'Teti');
    lRTFEngine.SetVar('today', DateToStr(date));
		
		//generate report passing 2 datasets in M/D relationship
    lRTFEngine.Parse(lRTFDocument, [ds1, ds2]);
		
    TFile.WriteAllText('MyReport.rtf', lRTFEngine.GetOutput);
  finally
    lRTFEngine.Free;
  end;
  ShellExecute(0, pchar('open'), pchar('MyReport.rtf'), nil, nil, SW_NORMAL);
end;
```

## Samples
Check the sample project to see supported language features
