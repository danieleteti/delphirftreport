object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'RTF Report Sample - Copyright 2016 Daniele Teti'
  ClientHeight = 451
  ClientWidth = 653
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter2: TSplitter
    Left = 209
    Top = 57
    Height = 394
    ExplicitLeft = 336
    ExplicitTop = 192
    ExplicitHeight = 100
  end
  object FileListBox1: TFileListBox
    Left = 0
    Top = 57
    Width = 209
    Height = 394
    Align = alLeft
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 25
    Mask = '*.rtf'
    ParentFont = False
    TabOrder = 0
    OnChange = FileListBox1Change
    OnDblClick = FileListBox1DblClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 653
    Height = 57
    Align = alTop
    TabOrder = 1
    object Button1: TButton
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 199
      Height = 49
      Align = alLeft
      Caption = 'Generate report'
      TabOrder = 0
      OnClick = Button1Click
    end
    object chkOpenGeneratedFile: TCheckBox
      Left = 209
      Top = 4
      Width = 161
      Height = 17
      Caption = 'Open Generated File'
      TabOrder = 1
    end
  end
  object PageControl1: TPageControl
    Left = 212
    Top = 57
    Width = 441
    Height = 394
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 2
    ExplicitLeft = 188
    ExplicitWidth = 465
    object TabSheet1: TTabSheet
      Caption = 'Output'
      ExplicitWidth = 457
      object reOutput: TRichEdit
        Left = 0
        Top = 0
        Width = 433
        Height = 366
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        Lines.Strings = (
          'reOutput')
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 0
        Zoom = 100
        ExplicitWidth = 457
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Report'
      ImageIndex = 1
      ExplicitWidth = 457
      object reReport: TRichEdit
        Left = 0
        Top = 0
        Width = 433
        Height = 366
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        Lines.Strings = (
          'reReport')
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 0
        Zoom = 100
        ExplicitWidth = 457
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Data'
      ImageIndex = 2
      ExplicitWidth = 457
      object Splitter1: TSplitter
        Left = 0
        Top = 153
        Width = 433
        Height = 3
        Cursor = crVSplit
        Align = alTop
        ExplicitTop = 120
        ExplicitWidth = 246
      end
      object DBGrid1: TDBGrid
        Left = 0
        Top = 0
        Width = 433
        Height = 153
        Align = alTop
        DataSource = DataSource1
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
      object DBGrid2: TDBGrid
        Left = 0
        Top = 156
        Width = 433
        Height = 210
        Align = alClient
        DataSource = DataSource2
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
    end
  end
  object ds1: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 248
    Top = 120
    object ds1id: TIntegerField
      FieldName = 'id'
    end
    object ds1name: TStringField
      FieldName = 'name'
      Size = 50
    end
    object ds1country: TStringField
      FieldName = 'country'
      Size = 50
    end
  end
  object ds2: TFDMemTable
    IndexFieldNames = 'id_person'
    MasterSource = DataSource1
    MasterFields = 'id'
    DetailFields = 'id_person'
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 392
    Top = 120
    object ds2id: TIntegerField
      FieldName = 'id'
    end
    object ds2id_person: TIntegerField
      FieldName = 'id_person'
    end
    object ds2contact: TStringField
      FieldName = 'contact'
      Size = 50
    end
    object ds2contact_type: TStringField
      FieldName = 'contact_type'
      Size = 50
    end
  end
  object DataSource1: TDataSource
    DataSet = ds1
    Left = 312
    Top = 120
  end
  object DataSource2: TDataSource
    DataSet = ds2
    Left = 456
    Top = 120
  end
end
