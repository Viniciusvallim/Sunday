Attribute VB_Name = "M�dulo4"
Sub AtualizarListaProjetos()
    Dim ws As Worksheet, projetos$
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
End Sub

