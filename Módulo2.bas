Attribute VB_Name = "M�dulo2"
Sub CriarListasSuspensasCadastro()
    Dim ws As Worksheet, projetos$, etapas$
    Set ws = ThisWorkbook.Sheets("CADASTRO")
    projetos = "Novo Projeto"
    Dim aba As Worksheet
    For Each aba In ThisWorkbook.Worksheets
        If aba.Name <> "CADASTRO" And aba.Name <> "Modelo_Gantt" Then
            projetos = projetos & "," & aba.Name
        End If
    Next aba
    ws.Range("B2").Validation.Delete
    ws.Range("B2").Validation.Add Type:=xlValidateList, Formula1:=projetos
    etapas = "Inicia��o,Planejamento,Execu��o,Testes T�cnicos,Infraestrutura e Log�stica,Implementa��o,Encerramento"
    ws.Range("B8").Validation.Delete
    ws.Range("B8").Validation.Add Type:=xlValidateList, Formula1:=etapas
    MsgBox "Listas suspensas criadas!", vbInformation
End Sub

