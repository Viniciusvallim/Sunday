Attribute VB_Name = "Módulo1"
Sub InserirTarefaProjeto()
    Dim wsCadastro As Worksheet
    Dim wsProj As Worksheet
    Dim etapas As Variant, posTitulos As Variant
    Dim blocoLinhas As Integer
    Dim etapaEscolhida As String
    Dim projetoNome As String
    Dim linhaEtapa As Long, linhaLivre As Long, linhaAtual As Long
    Dim ultimaLinhaQuadrante As Long
    Dim achouTarefa As Boolean
    Dim i As Integer
    
    Set wsCadastro = ThisWorkbook.Sheets("CADASTRO")
    projetoNome = wsCadastro.Range("B2").Value
    etapaEscolhida = wsCadastro.Range("B8").Value

    If projetoNome = "" Or etapaEscolhida = "" Then
        MsgBox "Selecione o projeto e a etapa!", vbExclamation
        Exit Sub
    End If
    On Error Resume Next
    Set wsProj = ThisWorkbook.Sheets(projetoNome)
    On Error GoTo 0
    If wsProj Is Nothing Then
        MsgBox "Projeto não encontrado!", vbCritical
        Exit Sub
    End If
    
    etapas = Array("Iniciação", "Planejamento", "Execução", "Testes Técnicos", _
                   "Infraestrutura e Logística", "Implementação", "Encerramento")
    posTitulos = Array(11, 17, 23, 29, 35, 41, 47)
    blocoLinhas = 6
    
    ' Localiza o bloco/quadrante correto
    linhaEtapa = 0
    For i = 0 To UBound(etapas)
        If wsProj.Range("B" & posTitulos(i)).Value = etapaEscolhida Then
            linhaEtapa = posTitulos(i)
            Exit For
        End If
    Next i
    If linhaEtapa = 0 Then
        MsgBox "Quadrante/Etapa não encontrado!", vbCritical
        Exit Sub
    End If

    achouTarefa = False
    ' Primeira tentativa: substituir "Tarefa X"
    For linhaAtual = linhaEtapa + 1 To linhaEtapa + blocoLinhas - 1
        If wsProj.Range("B" & linhaAtual).Value Like "Tarefa *" Then
            achouTarefa = True
            linhaLivre = linhaAtual
            Exit For
        End If
    Next linhaAtual

    ' Se não encontrou "Tarefa X", busca a última linha do quadrante e insere nova linha ali
    If Not achouTarefa Then
        ultimaLinhaQuadrante = linhaEtapa + blocoLinhas - 1
        Do While wsProj.Range("B" & (ultimaLinhaQuadrante + 1)).Value = "" And _
                  wsProj.Range("B" & (ultimaLinhaQuadrante + 1)).Interior.Color = wsProj.Range("B" & linhaEtapa).Interior.Color
            ultimaLinhaQuadrante = ultimaLinhaQuadrante + 1
        Loop
        
        linhaLivre = ultimaLinhaQuadrante + 1
        wsProj.Rows(linhaLivre).Insert Shift:=xlDown
        wsProj.Rows(linhaLivre - 1).Copy
        wsProj.Rows(linhaLivre).PasteSpecial xlPasteFormats
        Application.CutCopyMode = False
        wsProj.Range("B" & linhaLivre & ":G" & linhaLivre).ClearContents
    End If

    ' Preenche os dados na linha livre
    wsProj.Range("B" & linhaLivre).Value = wsCadastro.Range("B9").Value      ' Tarefa
    wsProj.Range("C" & linhaLivre).Value = ""                                ' Categoria (deixa em branco)
    wsProj.Range("D" & linhaLivre).Value = wsCadastro.Range("B10").Value     ' Responsável
    wsProj.Range("E" & linhaLivre).Value = ""                                ' Progresso
    wsProj.Range("F" & linhaLivre).Value = wsCadastro.Range("B11").Value     ' Início
    wsProj.Range("G" & linhaLivre).Value = wsCadastro.Range("B12").Value     ' Prazo

    ' Limpa todos os campos de cadastro B2:B12
    wsCadastro.Range("B2:B12").ClearContents

    MsgBox "Tarefa inserida/atualizada no quadrante com sucesso!", vbInformation
End Sub





