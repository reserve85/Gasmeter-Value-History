object Graph: TGraph
  Left = 0
  Top = 0
  Caption = 'Graph'
  ClientHeight = 1217
  ClientWidth = 2026
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  WindowState = wsMaximized
  OnResize = FormResize
  OnShow = FormShow
  TextHeight = 15
  object pnlDailyOverall: TPanel
    Left = 0
    Top = 400
    Width = 2026
    Height = 417
    Align = alClient
    TabOrder = 0
    object chtDailyOverall: TChart
      Left = 1
      Top = 1
      Width = 2024
      Height = 415
      Title.Text.Strings = (
        'Daily graph')
      BottomAxis.Title.Caption = '[Date]'
      LeftAxis.Title.Caption = '[kWh]'
      View3D = False
      Align = alClient
      TabOrder = 0
      OnMouseDown = chtDailyOverallMouseDown
      DefaultCanvas = 'TGDIPlusCanvas'
      PrintMargins = (
        15
        18
        15
        18)
      ColorPaletteIndex = 13
      object lnsrsDailyOverall: TLineSeries
        HoverElement = [heCurrent]
        Legend.Visible = False
        ShowInLegend = False
        Brush.BackColor = clDefault
        Pointer.HorizSize = 6
        Pointer.InflateMargins = True
        Pointer.Style = psCircle
        Pointer.VertSize = 6
        Pointer.Visible = True
        XValues.DateTime = True
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
    end
  end
  object pnlYearly: TPanel
    Left = 0
    Top = 817
    Width = 2026
    Height = 400
    Align = alBottom
    TabOrder = 1
    object pnlYear: TPanel
      Left = 1
      Top = 1
      Width = 2024
      Height = 32
      Align = alTop
      TabOrder = 0
      object lblActiveYear: TLabel
        Left = 185
        Top = 1
        Width = 1654
        Height = 30
        Align = alClient
        Alignment = taCenter
        Caption = 'lblActiveYear'
        Layout = tlCenter
        ExplicitWidth = 68
        ExplicitHeight = 15
      end
      object btnPreviousYear: TButton
        Left = 1
        Top = 1
        Width = 184
        Height = 30
        Align = alLeft
        Caption = 'Previous Year'
        TabOrder = 0
        OnClick = btnPreviousYearClick
      end
      object btnNextYear: TButton
        Left = 1839
        Top = 1
        Width = 184
        Height = 30
        Align = alRight
        Caption = 'Next Year'
        TabOrder = 1
        OnClick = btnNextYearClick
      end
    end
    object chtYearly: TChart
      Left = 1
      Top = 33
      Width = 1607
      Height = 366
      Legend.Visible = False
      Title.Text.Strings = (
        'Gas consumtion by month')
      BottomAxis.LabelsSeparation = 0
      BottomAxis.Title.Caption = '[Month]'
      BottomAxis.Items = {
        0C0000000104546578740608446563656D6265720556616C7565050000000000
        0000B002400001045465787406084E6F76656D6265720556616C756505000000
        00000000A002400001045465787406074F63746F6265720556616C7565050000
        000000000090024000010454657874060953657074656D6265720556616C7565
        05000000000000008002400001045465787406064175677573740556616C7565
        0500000000000000E001400001045465787406044A756C790556616C75650500
        000000000000C001400001045465787406044A756E650556616C756505000000
        00000000A001400001045465787406034D61790556616C756505000000000000
        00800140000104546578740605417072696C0556616C75650500000000000000
        C000400001045465787406054D617263680556616C7565050000000000000080
        004000010454657874060846656272756172790556616C756505000000000000
        0080FF3F0001045465787406074A616E7561727900}
      LeftAxis.Title.Caption = '[kWh]'
      LeftAxis.Items = {
        060000000104546578740605312E3230300556616C7565050000000000000096
        0940000104546578740605312E3030300556616C75650500000000000000FA08
        400001045465787406033830300556616C75650500000000000000C808400001
        045465787406033630300556616C756505000000000000009608400001045465
        787406033430300556616C75650500000000000000C807400001045465787406
        033230300556616C75650500000000000000C8064000}
      Align = alClient
      TabOrder = 1
      DefaultCanvas = 'TGDIPlusCanvas'
      PrintMargins = (
        15
        18
        15
        18)
      ColorPaletteIndex = 13
      object brsrsYearly: TBarSeries
        HoverElement = []
        Legend.Visible = False
        ShowInLegend = False
        MultiBar = mbNone
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Bar'
        YValues.Order = loNone
      end
    end
    object pnlStatistics: TPanel
      Left = 1608
      Top = 33
      Width = 417
      Height = 366
      Align = alRight
      Caption = 'pnlStatistics'
      TabOrder = 2
      object redtStatistics: TRichEdit
        Left = 1
        Top = 1
        Width = 415
        Height = 364
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        Lines.Strings = (
          'redtStatistics')
        ParentFont = False
        TabOrder = 0
      end
    end
  end
  object pnlOverall: TPanel
    Left = 0
    Top = 0
    Width = 2026
    Height = 400
    Align = alTop
    TabOrder = 2
    object chtOverall: TChart
      Left = 1
      Top = 1
      Width = 2024
      Height = 398
      Title.Text.Strings = (
        'Overall graph')
      BottomAxis.Title.Caption = '[Date]'
      LeftAxis.Title.Caption = '[m'#179']'
      View3D = False
      Align = alClient
      TabOrder = 0
      OnMouseDown = chtOverallMouseDown
      DefaultCanvas = 'TGDIPlusCanvas'
      PrintMargins = (
        15
        18
        15
        18)
      ColorPaletteIndex = 13
      object lnsrsOverall: TLineSeries
        HoverElement = [heCurrent]
        Legend.Visible = False
        ShowInLegend = False
        Brush.BackColor = clDefault
        Pointer.HorizSize = 6
        Pointer.InflateMargins = True
        Pointer.Style = psCircle
        Pointer.VertSize = 6
        Pointer.Visible = True
        XValues.DateTime = True
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
    end
  end
end
