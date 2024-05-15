Function fOut-Notepad {
	<#
		.NOTES
			Author: Buchser Roger
			
		.SYNOPSIS
			Output will be pasted in Windows Notepad instead of the Console. Function typically only used Internally in Script.
			
		.DESCRIPTION
			Sometime it is useful to enter Code to Notepad before entering it direct to Powershell.
			In Notepad, you can check and correct the code and then manually copy and Paste the Code to the Shell.
			
		.PARAMETER Text
			Enter the Text to sent to Notepad.
			
		.EXAMPLE
			fOut-Notepad -Text "Set-TransportConfig -MaxSendSize 25MB -MaxReceiveSize 25MB"
			Instead of paste and execute this Code direct to Shell, the Code will be pasted to Windows Notepad.
			You can Check and maybe modify the Code before manully Copy & Paste the Code to Shell.
			
		.EXAMPLE
			# Example with multiple Lines
			$Cmd = "Set-TransportConfig -MaxSendSize 25MB" | Out-String
			$Cmd += "Set-TransportConfig -MaxReceiveSize 25MB" | Out-String
			$Cmd | fOutNotepad
			
			The same code as above, but not in one Line. The final Code have in two Lines.
			
		.LINK
			https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/out-notepad-send-information-to-notepad
	#>
	
	[Alias("Out-Notepad")]
	
	PARAM (
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)][AllowEmptyString()][String]$Text
	)
	
	Begin {
		$sb = New-Object System.Text.StringBuilder
	} Process {
		$Null = $sb.AppendLine($Text)
	} End {
		$Text = $sb.ToString()
		$Process = Start-Process notepad -PassThru
		$Null = $process.WaitForInputIdle()
		$sig = '
		[DllImport("user32.dll", EntryPoint = "FindWindowEx")]public static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindow);
		[DllImport("User32.dll")]public static extern int SendMessage(IntPtr hWnd, int uMsg, int wParam, string lParam);
		'
		$Type = Add-Type -MemberDefinition $sig -Name APISendMessage -PassThru
		$hwnd = $process.MainWindowHandle
		[IntPtr]$child = $Type::FindWindowEx($hwnd, [IntPtr]::Zero, "Edit", $Null)
		$Null = $Type::SendMessage($Child, 0x000C, 0, $Text)
	}
}
