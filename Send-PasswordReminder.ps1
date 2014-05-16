# Send-PasswordReminder 
#
# Written By: JB Lewis
# Date: 27-July-2011
#
# Updated to an ADvanced Function - 5/16/2014

##########################################
# Functions
function truncate-log($LogFilePath, $LinesToKeep)
{
	$f = ${$LogFilePath}
	$count = $f.count
	if ($count -gt $LinesToKeep)
	{
		$f | select -last $LinesToKeep | Set-content $LogFilePath
	}
}

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.PARAMETER email
    email address of user this cmdlet notifies
.PARAMETER FirstName
    first name of the user this cmdlet notifies
.PARAMETER LastName
    last name of the user this cmdlet notifies
.PARAMETER PasswordExpires
    Password expiration date of the user this cmdlet notifies.  
    Can be either a DateTime object, as from Get-QADUser, or a filetime value, as from get-ADUSer.
.PARAMETER SMTPServer
    Fully qualified domain name of the SMTP server you are sending through.  
    Certain settings on the SMTP server may cause it to believe this script is spamming.
.PARAMETER SenderAddress
    email address to use as the sender.
.PARAMETER LogFile
    Full path and filename for the logfile.  If left blank will create a file in the same directory the script is launched from.
.PARAMETER Loglines
    Number of lines to retain in the logfile.
.EXAMPLE
    Get-QADUser -includedProperties PasswordExpires | Send-PasswordReminder -SMTPServer mysmtp.domain.com -SenderAddress IT@domain.com
    Gets the users in AD, and notifies those whose passwords will exipre soon.
.EXAMPLE
    Get-ADUser -Filter {enabled -eq  $True} -Properties "msds-UserPasswordExpiryTimeComputed","mail" 

#>
Function Send-PasswordReminder {
    [CmdletBinding()]
    param (
        # email Address
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        $email,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Alias("givenName")]
        $FirstName,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Alias("surname")]
        $LastName,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Alias("msds-UserPasswordExpiryTimeComputed")]
        $PasswordExpires,

        # smtp server to send with
        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]
        $SMTPServer,

        # email address to use as sender
        [Parameter(Mandatory=$true,
                   Position=2)]
        [string]
        $SenderAddress,

        # Log file full path and filename
        [Parameter(Mandatory=$false,
                   Position=3)]
        [String]
        $LogFile = "(Split-Path -parent $MyInvocation.MyCommand.Definition)\Send-PasswordReminder.log",

        # Number of lines to keep in the logfile
        [int]
        $LogLines = 5000
    )
    Begin {
        $mailer = new-object Net.Mail.SmtpClient ($smtpserver)
    
        $Today = Get-Date
        Add-Content -Path $LogFile -Value "$(Get-Date -Format g) - Starting"

        # $Days: Edit this array of values, adding a value for each reminder you want sent 
        # equal to the number of days before the user's password is set to expire.
        # Need to implement as a parameter!
        $days = "14","3","1"
    } # Begin Block

    Process {
        Foreach ($Day in $days) {
	        if ($Day -gt 1){$plural = "s"} else { $plural = ""}
            if (($PasswordExpires.gettype().fullname) -ne "System.DateTime"){
                $PasswordExpires = [DateTime]::FromFileTime($PasswordExpires)
            }

		    if (($PasswordExpires).dayofyear -eq ($Today.AddDays($Day)).dayofyear ) {
			    # Send an email
			    $msg = new-object Net.Mail.MailMessage
    		    $msg.From = $SenderAddress
   			    $msg.To.Add($($user.Email))
    		    $msg.subject = "Your Password expires in $Day day$plural"
    # Format and word the body message as you wish.
    		    $msg.Body = @"
    <html>
    <head>
	    <style type="text/css">
		    body {
			    font-family: Verdana, Arial, Helvetica, sans-serif;
			    font-size: x-small;
			    background: #fff;
			    color: #000;
			    }
		    table {
			    border-width: 1px;
			    border-style: solid;
			    border-color: #003878;
			    border-spacing: 15px;
			    background-color: white;
			    }
	    </style>
    </head>
    <body>
	    <table width="620">
		    <tr>
			    <td align="left" valign="top">
				    <p><strong>Dear $($user.FirstName) $($user.LastName),</strong></p>
				    <p>Just a friendly reminder that your Domain password expires $Day day$plural from Now.</p>
				    <ul>
				    <li>
				    <P>Option 1</P>
				    <P>Please update your Domain password by pressing the Ctrl + Alt + Delete keys simultaneously from your Windows workstation and selecting 'Change Password' from the available options.</P>
				    <P>Note: If you are a remote user, you will have to be connected to the VPN for this to work. Please restart your workstation after changing your password.</P>
				    </li>
				    <li>
				    <P>Option 2</P>
				    <P>Connect to <a href="https://citrix.adatum.com">https://citrix.adatum.com</A> and login (<redacted> is the domain).  After you login you will be given the option to Change Password.  After changing your password, you should then be able to connect VPN by logging into <A href="https://remote.covidien.com">https://remote.covidien.com</A>.  After you log into VPN please hit Ctrl + Alt + Delete key simultaneously and then “Lock” your computer and “Unlock” your computer with your new password.</P>
				    <P>Note: This option can also be used if you miss the date that your password expires.</P>
				    </li>
				    </ul>
				    <P><strong>For iPhone and iPad users:</strong>  After you have completed the steps listed above, follow these next steps to apply your new password to your iPad and/or iPhone.  Open the <i>Settings</i> icon from the home screen of your device, open <i>Mail, Contacts, Calendars</i>, open the account called <i>Covidien Exchange</i>, then open the account listed with your company email address, finally enter your new password in the <i>Password</i> field.</P>
				    <P>Remember, if you do not change your password before it expires you could be locked out from accessing internal company resources until an Administrator unlocks your account.</p>
				    <P><i>Passwords must be a minimum of 8 characters and Require 3 of the 4 characteristics below:</i></p>
				    <ul>
				    <li>Lower case letter</li>
				    <li>Capital Letter</li>
				    <li>Numeral</li>
				    <li>Special Characters ($,#,*, !, etc.)</li>
				    </ul>
				    <P>*Note: Additional requirements will limit password re-use, frequent password changes, as well as using your first or last name.</p>
				    <p>If you have any questions or need further assistance, please contact your IT Service Desk.</p>
				    <p>&nbsp;</p>
				    <p>Thank you,</p>
				    <p><strong><redacted> - IT Service Desk </strong></p>
				    <p><strong>888-555-1234</strong></p>
			    </td>
		    </tr>
	    </table>
    </body>
    </html>
"@
			    $msg.IsBodyHTML = $true 
			
			    $mailer.send($msg)
			
			    $msg = $null
			    Write-Verbose "$user's password will expire in $day days, on $($user.PasswordExpires)"
			    # It would be easy to add some logging here.
			    Add-Content -Path $LogFile -Value "$(Get-Date) - $user notified $day days prior to expiration"
		    } # if passwordexipres
        } #Foreach Day
    } # Process Block
    End {
        truncate-log $LogFile, $logLines
    } # End Block
}
