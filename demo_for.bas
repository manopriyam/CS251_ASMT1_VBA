For i = 1 To 5
        ' Check if the current value of i is even
        If i Mod 2 > 0 Then
            ' If i is even, add it to the result
            result = result + i
        Else
            ' If i is odd, subtract it from the result
            result = result - i
        End If
    Next i
    

