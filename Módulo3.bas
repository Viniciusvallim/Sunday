Attribute VB_Name = "Módulo3"


Sub CriarNovoProjeto()
    Dim wsCadastro As Worksheet, wsModelo As Worksheet, wsProj As Worksheet
    Dim projetoNome$, lider$, empresa$, prazo$
    Dim etapas, i As Integer, linhaTitulo As Integer
    Dim aba As Worksheet, colUltima$
    Dim dtInicioTexto As String
    Dim dtInicioDate As Date, prazoNum As Long, prevTermino As String

    Set wsCadastro = ThisWorkbook.Sheets("CADASTRO")
    Set wsModelo = ThisWorkbook.Sheets("Modelo_Gantt")
    colUltima = "BL"  ' Ajuste conforme o seu modelo

    projetoNome = wsCadastro.Range("B3").Value
    lider = wsCadastro.Range("B4").Value
    empresa = "TECPARTS"
    prazo = wsCadastro.Range("B7").Value

    ' Pega o que é exibido na célula B6 como texto
    dtInicioTexto = wsCadastro.Range("B6").Text

    If projetoNome = "" Then
        MsgBox "Preencha o nome do projeto!", vbExclamation
        Exit Sub
    End If

    ' Calcula a previsão do término (data início + prazo)
    On Error Resume Next
    dtInicioDate = DateSerial(Mid(dtInicioTexto, 7, 4), Mid(dtInicioTexto, 4, 2), Mid(dtInicioTexto, 1, 2))
    On Error GoTo 0
    If IsDate(dtInicioDate) And IsNumeric(prazo) Then
        prazoNum = CLng(prazo)
        prevTermino = Format(DateAdd("d", prazoNum, dtInicioDate), "dd/mm/yyyy")
    Else
        prevTermino = ""
    End If

    ' Evita duplicidade de aba
    For Each aba In ThisWorkbook.Worksheets
        If aba.Name = projetoNome Then
            MsgBox "Já existe uma aba para esse projeto!", vbCritical
            Exit Sub
        End If
    Next aba

    ' Cria nova aba cópia do modelo
    wsModelo.Copy After:=ThisWorkbook.Sheets(ThisWorkbook.Sheets.Count)
    Set wsProj = ActiveSheet
    wsProj.Name = projetoNome

    ' ==== CABEÇALHO ====
    With wsProj
        .Range("B2").Value = projetoNome
        .Range("B2:G2").Merge
        .Range("B2").Font.Size = 18
        .Range("B2").Font.Bold = True
        .Range("B2").Interior.Color = RGB(0, 97, 128)
        .Range("B2").Font.Color = vbWhite
        .Range("B2").HorizontalAlignment = xlLeft

        .Range("B4").Value = "Projeto:"
        .Range("B4").Font.Bold = True
        .Range("C4").Value = projetoNome

        .Range("E4").Value = "Líder:"
        .Range("E4").Font.Bold = True
        .Range("F4").Value = lider

        .Range("B5").Value = "Empresa:"
        .Range("B5").Font.Bold = True
        .Range("C5").Value = empresa

        .Range("B6").Value = "Data de Início:"
        .Range("B6").Font.Bold = True
        .Range("C6").NumberFormat = "@"   ' Força texto
        .Range("C6").Value = "'" & dtInicioTexto   ' Força texto fiel ao que aparece

        .Range("E6").Value = "Previsão Térmi:"
        .Range("E6").Font.Bold = True
        .Range("F6").Value = prevTermino
        .Range("F6").NumberFormat = "dd/mm/yyyy"

        .Range("B7").Value = "Incremento de Rolagem:"
        .Range("B7").Font.Bold = True
        .Range("C7").Value = 1

        .Range("E5:F5").ClearContents
        .Columns("F:F").ColumnWidth = 13
    End With

    ' ==== ETAPAS/QUADRANTES DO GANTT ====
    etapas = Array("Iniciação", "Planejamento", "Execução", "Testes Técnicos", _
                   "Indicadores e Monitoramento", "Infraestrutura e Logística", _
                   "Implantação", "Encerramento")
    linhaTitulo = 11
    For i = 0 To UBound(etapas)
        wsProj.Range("B" & linhaTitulo).Value = etapas(i)
        linhaTitulo = linhaTitulo + 6
    Next i

    wsCadastro.Range("B2:B8").ClearContents

    On Error Resume Next
    Call AtualizarListaProjetos
    On Error GoTo 0

    MsgBox "Projeto criado com sucesso!", vbInformation
End Sub


