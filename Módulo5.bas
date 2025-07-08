Attribute VB_Name = "Módulo5"
Sub BuscarPendencias()
    Dim wsPend As Worksheet
    Dim wsCont As Worksheet
    Set wsPend = ThisWorkbook.Sheets("PENDÊNCIAS")
    Set wsCont = ThisWorkbook.Sheets("CONTATOS")
    
    Dim filtroResp$, filtroDias$, filtroProjeto$
    filtroResp = Trim(wsPend.Range("B2").Value)
    filtroDias = wsPend.Range("B3").Value
    filtroProjeto = Trim(wsPend.Range("B4").Value)
    
    ' Limpa resultados antigos e cabeçalho
    wsPend.Range("A10:G1000").ClearContents
    wsPend.Range("A10:G10").Font.Bold = True
    wsPend.Range("A10:G10").Interior.Color = RGB(0, 97, 128)
    wsPend.Range("A10:G10").Font.Color = vbWhite
    
    ' Cabeçalho bonito
    Dim cabec
    cabec = Array("Projeto", "Tarefa", "Dias a vencer", "Dias vencidos", "Responsável", "E-mail", "Enviar e-mail")
    wsPend.Range("A10:G10").Value = cabec
    wsPend.Range("A10:G10").HorizontalAlignment = xlCenter
    
    Dim linhaSaida As Long: linhaSaida = 11
    Dim corFundo: corFundo = RGB(242, 242, 242)
    
    ' Percorre abas de projetos
    Dim ws As Worksheet, projNome$, tarefa$, resp$, dtInicio$, duracao$
    Dim i&, l&, dtFim As Date, diasRest As Variant, camposOk As Boolean, emailResp$
    
    For Each ws In ThisWorkbook.Worksheets
        If ws.Name <> "CADASTRO" And ws.Name <> "PENDÊNCIAS" And ws.Name <> "Modelo_Gantt" And ws.Name <> "CONTATOS" Then
            projNome = ws.Name
            l = 12 ' Primeira linha de tarefa
            Do While ws.Range("B" & l).Value <> ""
                ' Pular linhas de título de etapa (negrito)
                If ws.Range("B" & l).Font.Bold Then l = l + 1: GoTo ProximaLinhaLoop
                tarefa = ws.Range("B" & l).Value
                resp = ws.Range("D" & l).Value
                dtInicio = ws.Range("F" & l).Value
                duracao = ws.Range("G" & l).Value
                camposOk = True
                diasRest = ""
                
                ' Só considera se tiver tarefa, data e duração numérica
                If tarefa <> "" And IsDate(dtInicio) And IsNumeric(duracao) Then
                    dtFim = DateAdd("d", CLng(duracao), CDate(dtInicio))
                    diasRest = dtFim - Date
                Else
                    camposOk = False
                End If
                
                ' Filtros
                If filtroResp <> "" Then
                    If InStr(1, UCase(resp), UCase(filtroResp), vbTextCompare) = 0 Then camposOk = False
                End If
                If filtroProjeto <> "" Then
                    If UCase(projNome) <> UCase(filtroProjeto) Then camposOk = False
                End If
                If IsNumeric(filtroDias) And filtroDias <> "" Then
                    If diasRest = "" Then
                        camposOk = False
                    ElseIf diasRest > CLng(filtroDias) Then
                        camposOk = False
                    End If
                ElseIf Not IsNumeric(filtroDias) Or filtroDias = "" Then
                    If diasRest <> "" And diasRest >= 0 Then camposOk = False ' Só atrasados
                End If
                
                ' Busca e-mail do responsável
                emailResp = ""
                If resp <> "" Then
                    Dim cel As Range
                    For Each cel In wsCont.Range("A2:A" & wsCont.Cells(wsCont.Rows.Count, "A").End(xlUp).Row)
                        If Trim(UCase(cel.Value)) = Trim(UCase(resp)) Then
                            emailResp = cel.Offset(0, 1).Value
                            Exit For
                        End If
                    Next cel
                End If
                
                ' Escreve na aba de pendências se passar no filtro
                If camposOk And tarefa <> "" Then
                    With wsPend
                        .Range("A" & linhaSaida).Value = projNome
                        .Range("B" & linhaSaida).Value = tarefa
                        .Range("C" & linhaSaida).Value = IIf(diasRest >= 0, diasRest, "")
                        .Range("D" & linhaSaida).Value = IIf(diasRest < 0, Abs(diasRest), "")
                        .Range("E" & linhaSaida).Value = resp
                        .Range("F" & linhaSaida).Value = emailResp
                        .Range("G" & linhaSaida).Value = "Enviar"
                        If linhaSaida Mod 2 = 0 Then
                            .Range("A" & linhaSaida & ":G" & linhaSaida).Interior.Color = corFundo
                        End If
                    End With
                    linhaSaida = linhaSaida + 1
                End If
ProximaLinhaLoop:
                l = l + 1
            Loop
        End If
    Next ws

    ' Monta hiperlinks na coluna "Enviar e-mail"
    Dim ultLinha As Long, iLinha As Long
    ultLinha = wsPend.Cells(wsPend.Rows.Count, "A").End(xlUp).Row
    For iLinha = 11 To ultLinha
        If wsPend.Cells(iLinha, 7).Value = "Enviar" Then
            wsPend.Hyperlinks.Add Anchor:=wsPend.Cells(iLinha, 7), _
                Address:="", _
                SubAddress:="'PENDÊNCIAS'!G" & iLinha, _
                TextToDisplay:="Enviar"
        End If
    Next iLinha
End Sub

Sub EnviarEmailPendencia()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("PENDÊNCIAS")
    Dim linha As Long
    linha = ActiveCell.Row
    Dim emailResp$, nomeResp$, tarefa$, projeto$, diasRest$, diasVenc$, corpo$
    
    projeto = ws.Cells(linha, 1).Value
    tarefa = ws.Cells(linha, 2).Value
    diasRest = ws.Cells(linha, 3).Value
    diasVenc = ws.Cells(linha, 4).Value
    nomeResp = ws.Cells(linha, 5).Value
    emailResp = ws.Cells(linha, 6).Value
    
    If emailResp = "" Then
        MsgBox "E-mail do responsável não encontrado!", vbExclamation
        Exit Sub
    End If
    
    corpo = "Olá " & nomeResp & "," & vbCrLf & vbCrLf & _
        "Você possui uma pendência no projeto: " & projeto & vbCrLf & _
        "Tarefa: " & tarefa & vbCrLf
    If diasRest <> "" Then
        corpo = corpo & "Dias até o vencimento: " & diasRest & vbCrLf
    ElseIf diasVenc <> "" Then
        corpo = corpo & "Dias vencidos: " & diasVenc & vbCrLf
    End If
    corpo = corpo & vbCrLf & "Favor verificar e atualizar o andamento." & vbCrLf & vbCrLf & "Obrigado."
    
    Dim outlookApp As Object, outlookMail As Object
    Set outlookApp = CreateObject("Outlook.Application")
    Set outlookMail = outlookApp.CreateItem(0)
    With outlookMail
        .To = emailResp
        .Subject = "Pendência Projeto: " & projeto
        .Body = corpo
        .Display ' ou .Send para enviar direto
    End With
    Set outlookMail = Nothing
    Set outlookApp = Nothing
    MsgBox "E-mail pronto para envio!", vbInformation
End Sub

