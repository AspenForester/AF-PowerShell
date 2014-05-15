$HCVMVlanDataPreference = "\\zanzibar\GSOSTeam\Server Setup Script\build v4\build.v4\VLAN-Reference.csv"

<#
.Synopsis
   Checks the input datafile for accurate matches between the gateway, Netmask, and Network.
.DESCRIPTION
   Checks the input datafile for accurate matches between the gateway, Netmask, and Network.
   Uses a reference table stored as a CSV file which can be specified with the datafile parameter
.PARAMETER Datafile
   Full path and filename for the CSV file to check.  Defaults to the value of the HCVMVLANDataPreference variable
.NOTES
   Original Author: JB Lewis 
   February 27, 2014
   ToDo: Create a custom type and format, tabular output makes the most sense.
.EXAMPLE
   Confirm-HCVMDataFile -DataFile c:\data\reference.csv
.EXAMPLE
   Confirm-HCVMDataFile -DataFile $HCVMVlanDataPreference | ft

#>
function Confirm-HCVMDataFile {
    #requires -version 3
    [CmdletBinding()]
   
    Param
    (
        # DataFile path if it isn't close by.
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$false,
                   Position=0)]
        [String]
        $DataFile = $HCVMVlanDataPreference
    )
   <#
   Ver 1: 
   #>

    Begin
    {
        Import-Module netshell
        # Early versions will use a static datafile until we can find a usable, "true" data source.
        Write-Verbose "Attempting to load VLAN Reference data file"
        Try 
        {
            $vlandata = import-csv $DataFile
        }
        Catch
        {
            Throw "Unable to locate or load data file: $datafile"
        }
    }
    Process
    {
        Write-Verbose "Checking the mathematical accuracy of $datafile"

        foreach ($vlan in $vlandata){
            if ($vlan.gateway -ne ""){
                $DecIP = ConvertTo-DecimalIP $vlan.gateway

                $DecNetwork = ConvertTo-DecimalIP $vlan.Network
                $DecBroadcast = (ConvertTo-DecimalIP (Get-BroadcastAddress $vlan.network $vlan.netmask))
                $ipgtnetwork = $DecIP -gt $DecNetwork
                $ipltbroadcast = $DecIP -lt $DecBroadcast
                $NetworkMatches = $DecNetwork -eq (ConvertTo-DecimalIP (Get-NetworkAddress $vlan.gateway $vlan.netmask))

                If (!($ipgtnetwork -and $ipltbroadcast -and $NetworkMatches)){
                    [pscustomobject]@{
                        Gateway       = $vlan.gateway
                        GWgtNet       = $ipgtnetwork
                        GWltBroad     = $ipltbroadcast
                        NetworksMatch = $NetworkMatches
                        CalcNetwork   = $(Get-NetworkAddress $vlan.gateway $vlan.netmask)
                        VLAN          = $vlan.vlan
                    }
                }

            } # if $vlan.gateway not blank
            else {
                Write-Warning "Missing Gateway for VLAN $($vlan.vlan) : $($vlan.portgrouplabel)"
            }

        }
    }
    End
    {
        Write-Verbose "Done"
    }
}

<#
.Synopsis
   Determines networking settings from given a Domain and IP address
.DESCRIPTION
   Determines VLAN, Gateway, SubNet Mask, and DNS servers from in put pair of Domain and IP address.
   Uses a reference table stored as a CSV file which can be specified with the datafile parameter
.PARAMETER IPAddress
   IP address to check and return lookedup info about.
.PARAMETER DataFile
   Full path and filename of the CSV data file to reference.  Defaults to the value of variable HCVMVLANDataPreference
.NOTES
   Original Author: JB Lewis 
   February 14, 2014
.EXAMPLE
   Get-HCVMLanSettings -Domain Foo -IPAddress 1.1.1.1
.EXAMPLE
   Get-HCVMLanSettings -Domain Foo -IPAddress 1.1.1.1 -DataFile c:\data\reference.csv

#>
function Get-HCVMLanSettings {
    #requires -version 3
    [CmdletBinding()]
   
    Param
    (
        # IP address to validate
        [parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateScript({
            If ($_ -match "^(\d{1,3}\.){3}\d{1,3}$") {
                $True
            } Else {
                Throw "$_ is not a valid IPV4 address!"
            }
        })]
        [string]
        $IPAddress,

        # DataFile path if it isn't close by.
        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$false,
                   Position=1)]
        [String[]]
        $DataFile = $HCVMVlanDataPreference
    )
   <#
   Ver 1: 
   #>

    Begin
    {
        Import-Module netshell
        # Early versions will use a static datafile until we can find a usable, "true" data source.
        Write-Verbose "Attempting to load VLAN Reference data file"
        Try 
        {
            $vlandata = import-csv $DataFile
        }
        Catch
        {
            Throw "Unable to locate or load data file: $datafile"
        }
    }
    Process
    {
        Write-Verbose "Checking the IP address before we try to use it again: $IPAddress"
        if (-not (Test-Connection $IPAddress -Count 2 -Quiet)) {
            $DecIP = ConvertTo-DecimalIP $IPAddress
            Write-Verbose "$IPAddress = $DecIP"
            $vlandata | 
                Where-Object {(ConvertTo-DecimalIP $_.Network) -lt $DecIP -and $DecIP -lt (ConvertTo-DecimalIP (Get-BroadcastAddress $_.network $_.netmask))} |
                select VLAN,Gateway,NetMask,@{Name="DNSServers";Expression={@($_.pDNS,$_.sDNS)}},PortGroupLabel    
        } Else {
            Throw "$IpAddress is already in use"
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Displays a GUI for New Virtual Machine parameter settings
.DESCRIPTION
   Displays GUI for users to enter basic parameters for creating a new VMWare Virtual Machine.  
   Outputs the parameters to the pipeline for another function to use to create the new virtual machine.
   Currently has no parameters
.NOTES
   Original Author: JB Lewis 
   February 14, 2014
   Generated by Sapien Primal Forms Community Edition
.EXAMPLE
   Show-HCVMDefinitionPicker 
.EXAMPLE
   Show-HCVMDefinitionPicker | New-HCVMVirtualMachine

#>
function Show-HCVMDefinitionPicker {
#requires -version 3
    [CmdletBinding()]
    Param()


########################################################################
# Code Generated By: SAPIEN Technologies PrimalForms (Community Edition) v1.0.10.0
# Generated On: 2/20/2014 11:20 AM
# Generated By: jole001
########################################################################

#region Import the Assemblies
    [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
#endregion

#region Generated Form Objects
    $frmMain = New-Object System.Windows.Forms.Form
    $btnCancel = New-Object System.Windows.Forms.Button
    $btnOK = New-Object System.Windows.Forms.Button
    $DomOSVer = New-Object System.Windows.Forms.DomainUpDown
    $domDomain = New-Object System.Windows.Forms.DomainUpDown
    $lblOSVer = New-Object System.Windows.Forms.Label
    $lblDomain = New-Object System.Windows.Forms.Label
    $txtIPAddr = New-Object System.Windows.Forms.TextBox
    $txtVMName = New-Object System.Windows.Forms.TextBox
    $lblIPAddr = New-Object System.Windows.Forms.Label
    $lblVMName = New-Object System.Windows.Forms.Label
    $domCluster = New-Object System.Windows.Forms.DomainUpDown
    $lblCluster = New-Object System.Windows.Forms.Label
    $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
#endregion Generated Form Objects

#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------
#Provide Custom Code for events specified in PrimalForms.
    $btnOK_OnClick= 
    {
        Write-Verbose "$(get-date -Format g): User Clicked OK"
        If (-not ($txtIPAddr.Text -match "^(\d{1,3}\.){3}\d{1,3}$") ) {
            # Raise an alarm!
            [System.Windows.Forms.MessageBox]::Show("$($txtIPAddr.Text) is not a valid IPv4 address. Please try again.","Invalid IP")
        } Elseif (-not ($domDomain.SelectedItem) -or (-not ($domOSVer.SelectedItem)) -or (-not($domCluster.SelectedItem))) {
            [System.Windows.Forms.MessageBox]::Show("You must select a domain, an OS Version, and a cluster!","Required Input Missing")
        } else {
            $btnOK.Text = "Working!"
            Write-Verbose "Checking IP Address $($txtIPAddr.Text) in $($domDomain.SelectedItem) "
            Try {
                $everything_ok = $True
                $LanSettings = Get-HCVMLanSettings -IPAddress $($txtIPAddr.Text) -ErrorAction Stop 
            }
            Catch {
                $everything_ok = $false
                $lanErr = $_
                Write-Warning $LanErr.exception.message     
            }    
            #Write-Verbose $LanSettings
            if (! $everything_ok){
                $btnOK.Text = "OK"
                [System.Windows.Forms.MessageBox]::Show($LanErr.exception.message,"Warning")
            } elseIf (-not ($LanSettings)){ 
                # Raise an alarm!
                $btnOK.Text = "OK"
                [System.Windows.Forms.MessageBox]::Show("Unable to find a matching VLAN for the IP Address: $($txtIPAddr.Text). Please Try Again ","IP VLAN mismatch")
            } else {
            Write-Verbose "Creating output object"
            # Send the results to the pipeline
            $script:myResults = [PSCustomObject]@{vmname = $txtVMName.Text
                              IP = $txtIPAddr.Text
                              Gateway = $LanSettings.Gateway
                              SubnetMask = $LanSettings.netmask
                              VLAN = $lansettings.vlan
                              OS = $domOSVer.SelectedItem
                              Domain = $domDomain.SelectedItem
                              PortGroupLabel = $lansettings.portgrouplabel
                              Cluster = $domCluster.SelectedItem}

            $frmMain.Close() 
            }   
        } 
    }

    $btnCancel_OnClick= 
    {
        Write-Verbose "User clicked Cancel"
        $frmMain.Close()
    }

    $OnLoadForm_StateCorrection=
    {#Correct the initial state of the form to prevent the .Net maximized form issue
	    $frmMain.WindowState = $InitialFormWindowState
    }

#----------------------------------------------
#region Generated Form Code
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 262
    $System_Drawing_Size.Width = 284
    $frmMain.ClientSize = $System_Drawing_Size
    $frmMain.DataBindings.DefaultDataSourceUpdateMode = 0
    $frmMain.Name = "frmMain"
    $frmMain.Text = "Hennepin County VM tool"

    $domCluster.DataBindings.DefaultDataSourceUpdateMode = 0
    $domCluster.Items.Add("BCDRCluster")|Out-Null
    $domCluster.Items.Add("MGMTCluster")|Out-Null
    $domCluster.Items.Add("PRODCluster")|Out-Null
    $domCluster.Items.Add("STGCluster")|Out-Null
    $domCluster.Items.Add("VISIDMZCluster")|Out-Null
    $domCluster.Items.Add("WADCDMZCluster")|Out-Null
    $domCluster.Items.Add("XENCluster")|Out-Null
    $domCluster.Items.Add("DEVCluster")|Out-Null
    $domCluster.Items.Add("SELAB")|Out-Null
    $domCluster.Items.Add("PELAB")|Out-Null
    $domCluster.Items.Add("prodmirror")|Out-Null
    $domCluster.Items.Add("IVORYCluster")|Out-Null
    $domCluster.Items.Add("ORANGECluster")|Out-Null
    $domCluster.Items.Add("Blue Cluster")|Out-Null
    $domCluster.Items.Add("White Cluster")|Out-Null
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 13
    $System_Drawing_Point.Y = 147
    $domCluster.Location = $System_Drawing_Point
    $domCluster.Name = "domCluster"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 20
    $System_Drawing_Size.Width = 120
    $domCluster.Size = $System_Drawing_Size
    $domCluster.TabIndex = 4
    $domCluster.Text = "<Cluster>"

    $frmMain.Controls.Add($domCluster)

    $lblCluster.DataBindings.DefaultDataSourceUpdateMode = 0

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 13
    $System_Drawing_Point.Y = 120
    $lblCluster.Location = $System_Drawing_Point
    $lblCluster.Name = "lblCluster"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 23
    $System_Drawing_Size.Width = 100
    $lblCluster.Size = $System_Drawing_Size
    $lblCluster.TabIndex = 8
    $lblCluster.Text = "Cluster"

    $frmMain.Controls.Add($lblCluster)

    $btnCancel.DataBindings.DefaultDataSourceUpdateMode = 0

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 215
    $System_Drawing_Point.Y = 217
    $btnCancel.Location = $System_Drawing_Point
    $btnCancel.Name = "btnCancel"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 33
    $System_Drawing_Size.Width = 60
    $btnCancel.Size = $System_Drawing_Size
    $btnCancel.TabIndex = 7
    $btnCancel.Text = "Cancel"
    $btnCancel.UseVisualStyleBackColor = $True
    $btnCancel.add_Click($btnCancel_OnClick)

    $frmMain.Controls.Add($btnCancel)


    $btnOK.DataBindings.DefaultDataSourceUpdateMode = 0

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 13
    $System_Drawing_Point.Y = 217
    $btnOK.Location = $System_Drawing_Point
    $btnOK.Name = "btnOK"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 33
    $System_Drawing_Size.Width = 196
    $btnOK.Size = $System_Drawing_Size
    $btnOK.TabIndex = 6
    $btnOK.Text = "OK"
    $btnOK.UseVisualStyleBackColor = $True
    $btnOK.add_Click($btnOK_OnClick)

    $frmMain.Controls.Add($btnOK)

    $DomOSVer.DataBindings.DefaultDataSourceUpdateMode = 0
    $DomOSVer.Items.Add("w2008r2")|Out-Null
    $DomOSVer.Items.Add("w2012")|Out-Null
    $DomOSVer.Items.Add("w2012r2")|Out-Null
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 155
    $System_Drawing_Point.Y = 93
    $DomOSVer.Location = $System_Drawing_Point
    $DomOSVer.Name = "DomOSVer"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 20
    $System_Drawing_Size.Width = 120
    $DomOSVer.Size = $System_Drawing_Size
    $DomOSVer.TabIndex = 3
    $DomOSVer.Text = "<OS Version>"

    $frmMain.Controls.Add($DomOSVer)

    $domDomain.DataBindings.DefaultDataSourceUpdateMode = 0
    $domDomain.Items.Add("HC_ACCT")|Out-Null
    $domDomain.Items.Add("FR")|Out-Null
    $domDomain.Items.Add("ECOM")|Out-Null
    $domDomain.Items.Add("HCGGSE")|Out-Null
    $domDomain.Items.Add("FRSE")|Out-Null
    $domDomain.Items.Add("HCGGPE")|Out-Null
    $domDomain.Items.Add("FRPE")|Out-Null
    $domDomain.Items.Add("EGOV")|Out-Null
    $domDomain.Items.Add("EGOVPE")|Out-Null
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 12
    $System_Drawing_Point.Y = 93
    $domDomain.Location = $System_Drawing_Point
    $domDomain.Name = "domDomain"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 20
    $System_Drawing_Size.Width = 120
    $domDomain.Size = $System_Drawing_Size
    $domDomain.TabIndex = 2
    $domDomain.Text = "<domain>"

    $frmMain.Controls.Add($domDomain)

    $lblOSVer.DataBindings.DefaultDataSourceUpdateMode = 0

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 155
    $System_Drawing_Point.Y = 67
    $lblOSVer.Location = $System_Drawing_Point
    $lblOSVer.Name = "lblOSVer"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 23
    $System_Drawing_Size.Width = 100
    $lblOSVer.Size = $System_Drawing_Size
    $lblOSVer.TabIndex = 5
    $lblOSVer.Text = "OS Version"

    $frmMain.Controls.Add($lblOSVer)

    $lblDomain.DataBindings.DefaultDataSourceUpdateMode = 0

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 13
    $System_Drawing_Point.Y = 67
    $lblDomain.Location = $System_Drawing_Point
    $lblDomain.Name = "lblDomain"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 23
    $System_Drawing_Size.Width = 100
    $lblDomain.Size = $System_Drawing_Size
    $lblDomain.TabIndex = 4
    $lblDomain.Text = "AD Domain"

    $frmMain.Controls.Add($lblDomain)

    $txtIPAddr.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 155
    $System_Drawing_Point.Y = 40
    $txtIPAddr.Location = $System_Drawing_Point
    $txtIPAddr.Name = "txtIPAddr"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 20
    $System_Drawing_Size.Width = 100
    $txtIPAddr.Size = $System_Drawing_Size
    $txtIPAddr.TabIndex = 1

    $frmMain.Controls.Add($txtIPAddr)

    $txtVMName.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 13
    $System_Drawing_Point.Y = 40
    $txtVMName.Location = $System_Drawing_Point
    $txtVMName.Name = "txtVMName"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 20
    $System_Drawing_Size.Width = 100
    $txtVMName.Size = $System_Drawing_Size
    $txtVMName.TabIndex = 0

    $frmMain.Controls.Add($txtVMName)

    $lblIPAddr.DataBindings.DefaultDataSourceUpdateMode = 0

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 155
    $System_Drawing_Point.Y = 13
    $lblIPAddr.Location = $System_Drawing_Point
    $lblIPAddr.Name = "lblIPAddr"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 23
    $System_Drawing_Size.Width = 100
    $lblIPAddr.Size = $System_Drawing_Size
    $lblIPAddr.TabIndex = 1
    $lblIPAddr.Text = "IP Address"

    $frmMain.Controls.Add($lblIPAddr)

    $lblVMName.DataBindings.DefaultDataSourceUpdateMode = 0

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 13
    $System_Drawing_Point.Y = 13
    $lblVMName.Location = $System_Drawing_Point
    $lblVMName.Name = "lblVMName"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 23
    $System_Drawing_Size.Width = 100
    $lblVMName.Size = $System_Drawing_Size
    $lblVMName.TabIndex = 1
    $lblVMName.Text = "VM Name"

    $frmMain.Controls.Add($lblVMName)

#endregion Generated Form Code

    #Save the initial state of the form
    $InitialFormWindowState = $frmMain.WindowState
    #Init the OnLoad event to correct the initial state of the form
    $frmMain.add_Load($OnLoadForm_StateCorrection)
    #Show the Form
    $frmMain.ShowDialog()| Out-Null

    Write-Output $myResults

} #End Function Show-HCVMDefinitionPicker

<#
.Synopsis
   Creates a new VMWare Virtual Machine based on the paramters supplied
.DESCRIPTION
   Creates a new VMWare Virtual Machine based on the paramters supplied, including the the IP address, hostname, domain,
   vCenter Cluster, and Network/portgroup.  The IP is validated for preexisting use, and is used to determine the
   VLAN/network/portgroup.
.PARAMETER VMName
   Desired name for the new Virtual Machine - Not currently validated
.PARAMETER IP
   Desired IP address of the new Virtual Machine
.PARAMETER Domain
   AD Domain for the new Virtual Machine
.PARAMETER Cluster
   VIServer cluster for the new Virtual Machine
.PARAMETER OS
   Operating system ID for the new Virtual Machine. 
   Acceptable values are "w2008r2","w2008r2e","w2008r2d","w2012","w2012r2"
.PARAMETER Launch
   Specifies the path and filename of any script or executable to run during the autologin session following the completion of the build
   Defaults to "c:\build\elevate.bat"
.PARAMETER Template
   Specifies the VIServer template to use when creating the new VM.  If not specified, the value will be set equal to the OS variable.
.PARAMETER CPU
   Number of CPUs for the new VM. Defaults to 1 if omitted.
.PARAMETER Network
   Virtual Switch or Portgroup to connect the VM to
.PARAMETER SubnetMask
   Subnet Mask is checked for proper dotted decimal format. TCP/IP setting for new VM
.PARAMETER Gateway
   Gateway is checked for proper dotted decimal format. TCP/IP setting for new VM
.PARAMETER DNSServers
   One or more IP addresses of DNS servers. Addresses are checked for proper dotted decimal format
.PARAMETER DDrive
    Size, in GB, of the desired data drive.
.EXAMPLE
   New-HCVMVirtualMachine -vmname 'TestJBL' -ip 172.21.99.250 -domain hcggse -cluster SELAB -os w2012 -Verbose
   Creates the new guest VM with hostname "TestJBL", IP address 172.21.99.250, in the hcggse domain, SELAB cluster from 
   the "w2012" template.
.EXAMPLE
   Show-HCVMDefinitionPicker | New-HCVMVirtualMachine

   Use the GUI provided by Show-HCVMDefinitionPicker to select and pass the parameter values for new-HCVMVirtualMachine
#>
Function New-HCVMVirtualMachine {
#requires -version 3.0
# Allows the script to use the Common Parameters.
[CmdletBinding()]

Param (
    # Name of the new VM
    [Parameter(Mandatory=$true,
 #       ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0)]
	[string]$vmname,

    # Valid, unused IP Address
    [Parameter(Mandatory=$true,
  #      ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=1)]
    [ValidateScript({
        If ($_ -match "^(\d{1,3}\.){3}\d{1,3}$") {
            $True
        } Else {
            Throw "$_ is not a valid IPV4 address!"
        }
    })]
	[string]$ip,

    # AD Domain for new VM
    [Parameter(Mandatory=$true,
  #      ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=2)]
	[string]$domain,

    # name of VIServer Cluster container in which the new VM will be created
    [Parameter(Mandatory=$true,
  #      ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=3)]
	[string]$cluster,

    # Operating System of new VM
    [Parameter(Mandatory=$true,
  #      ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=4)]
    [ValidateSet("w2008r2","w2008r2e","w2008r2d","w2012","w2012r2")]
	[string]$os,

     # If not specified, launch defaults to "c:\build\elevate.bat" (optional)
    [Parameter(Mandatory=$false,
   #     ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
    [String]$launch = 'c:\build\elevate.bat',

    # Template to use (optional)
    [Parameter(Mandatory=$false,
 #       ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
    [String]$template,

    # cpu with a default value of 1 (optional)
    [Parameter(Mandatory=$false,
  #      ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
    [int]$cpu = 1,

    # Name of the Portgroup to connect the new VM to (optional)
    [Parameter(Mandatory=$false,
  #      ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
    [Alias("PortGroupLabel")]
    [string]$Network,

    # Default Subnet Mask (optional)
    [Parameter(Mandatory=$false,
  #      ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        If ($_ -match "^(\d{1,3}\.){3}\d{1,3}$") {
            $True
        } Else {
            Throw "$_ is not a valid IPV4 address!"
        }
    })]
    [Alias("NetMask")]
    [string]$SubnetMask,

    # Default Gateway (optional)
    [Parameter(Mandatory=$false,
  #      ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        If ($_ -match "^(\d{1,3}\.){3}\d{1,3}$") {
            $True
        } Else {
            Throw "$_ is not a valid IPV4 address!"
        }
    })]
    [Alias("DefaultGateway")]
    [string]$Gateway,

    # DNS servers (optional)
    [Parameter(Mandatory=$false,
 #       ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        $_ | foreach {
            If ($_ -match "^(\d{1,3}\.){3}\d{1,3}$") {
                $True
            } Else {
                Throw "$_ is not a valid IPV4 address!"
            }
        }
    })]
    [Alias("DNS")]
    [string[]]$DNSServers,

    [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
    [int]$DDrive
)

Begin {
    Write-Verbose "Starting the Begin Block"
    
    # Make sure this is running in a 32-bit session
    Write-Verbose "Testing for 32-bit session"
    if ([environment]::Is64BitProcess){
        Throw "This script must be run in a 32-bit session!"
    }

    #region Load PSSnapin
    Write-Verbose "Attempting to load the VMWare Core automation PSSnapin"
    $snapin = "vmware.vimautomation.core"
    if (Get-PSSnapin $snapin -ErrorAction SilentlyContinue){
        Write-Verbose "Snapin $snapin is loaded"
        $snapin_loaded = $true
    }
    Elseif (Get-PSSnapin $snapin -Registered -ErrorAction SilentlyContinue){
        Write-Verbose "Snapin $snapin is registered but not yet loaded."
        Add-PSSnapin $snapin | Out-Null
        $snapin_loaded = $true
    }
    else {
        Write-Verbose "Snapin $snapin not found!"
        $snapin_loaded = $false
    }
    #endregion Load PSSnapin  
    Set-PowerCLIConfiguration -DisplayDeprecationWarnings:$false -Confirm:$false | out-null
}
Process{
    Write-Verbose "Starting the Process Block"
    if ($snapin_loaded){

        # EagerZeroedThick throws an error in hcvcenter
        #$disktype = "EagerZeroedThick"  
        $disktype = "Thick"  

        $prod = "hcvcenter.hcgg.fr.co.hennepin.mn.us"
        $dev  = "dvvcenter.hcgg.fr.co.hennepin.mn.us"
        $wadc = "choir.hcgg.fr.co.hennepin.mn.us"
        $visi = "tune.hcgg.fr.co.hennepin.mn.us"
        $se   = "172.21.99.99"
        $pe   = "pevcenter.hcggpe.frpe.co.hennepin.mn.us"
        #FIX $ve   = "vevcenter.hcggve.frve.co.hennepin.mn.us" # does not yet exist

        # Select vcenter from cluster
        switch -wildcard ($cluster){
	        "bcdr*"		{ $cluster = "BCDRCluster"   ; $vcenter = $prod; break}
	        "mgmt*"		{ $cluster = "MGMTCluster"   ; $vcenter = $prod; break}
	        "prod*"		{ $cluster = "PRODCluster"   ; $vcenter = $prod; break}
	        "stg*"		{ $cluster = "STGCluster"    ; $vcenter = $prod; break}
	        "visidmz*"	{ $cluster = "VISIDMZCluster"; $vcenter = $prod; break}
	        "wadcdmz*"	{ $cluster = "WADCDMZCluster"; $vcenter = $prod; break}
	        "xen*"		{ $cluster = "XENCluster"    ; $vcenter = $prod; break}
	        "dev*"		{ $cluster = "DEVCluster"    ; $vcenter = $dev; break}
	        "selab*"	{ $cluster = "SELAB"         ; $vcenter = $se; break}
	        "prodm*"	{ $cluster = "prodmirror"    ; $vcenter = $se; break}
	        "ivory*"	{ $cluster = "IVORYCluster"  ; $vcenter = $visi ; $IsVC41 = $true; break }     # Consider $isVC41 as a boolean
	        "orange*"	{ $cluster = "ORANGECluster" ; $vcenter = $visi ; $IsVC41 = $true; break }     # Set $isvc41 = $true here
	        "blue*"	    { $cluster = "Blue Cluster"  ; $vcenter = $wadc ; $IsVC41 = $true; break }     # then later just use
	        "white*"	{ $cluster = "White Cluster" ; $vcenter = $wadc ; $IsVC41 = $true; break }     # if ($isvc41) {}
	        "pe*"		{ $cluster = "PECluster"     ; $vcenter = $pe; break}
	        #FIX	"ve*"      { $cluster = "" -and $vcenter = $ve;break}	
        }

        # Set the $template variable if we didn't get it from the params
        if (!$template){ $template = $os }
<#
        FIX: templates and customization specs need a naming standard to exist
        os template and spec naming standards need to be in place
        w2008r2  = windows server 2008r2 standard edition sp1
        w2008r2e = windows server 2008r2 enterprise edition sp1
        w2008r2d = windows server 2008r2 datacenter edition sp1
        w2012    = windows server 2012 standard
        w2012r2  = windows server 2012r2 standard
        ToDo: Validate the Template name.
#>
        Write-Verbose "Connecting to VIServer $vcenter"
        connect-viserver -server $vcenter -SaveCredentials | Out-Null # suppress the output.

        # Determine ideal host for new VM
        $vmhost = get-cluster $cluster | get-vmhost | sort $_.CPuUsageMhz  | select -first 1
        Write-Verbose "$($vmhost.name) selected as host for new VM"

        # PowerCLI bug: doesn't properly handle vCPUs vs vCPU cores.
        # symmetry is desired here
        if ($cpu -ne 1 -and $cpu % 2 -ne 0) { 
	        #$cpu += 1 
	        # FIX: temporary hack; powercli lacks support for numcores
	        # powercli api support for cores is weak
	        # expansion of cores will come in a later script version
	        $cpu = 2
        }

        # CPU looks like it should have a default value of 1, let's do that in the params instead.
        if (!$ram) {
            switch -wildcard ($template){
	            "*8r2*" {
		            $ram = 2
	            }
	            "*8r2e*" { # technically this should not get used here...
		            $ram = 2
	            }
	            "*8r2d*" { # technically this should not get used here...
		            $ram = 2
	            }
	            "*12*" {
		            $ram = 4
	            }
	            "*12r2*" {
		            $ram = 4
	            }
            }
        } # if (! $ram)

### Need to talk about this section
        # Set DNS Servers if they weren't provided
        if (! $DNSServers){
            switch -wildcard ($domain){
	            "hcgg.*" {
		            $DNSServers = "137.70.23.190","137.70.244.156","137.70.11.8"
		            break
	            }
	            "hc_acct" {
		            $DNSServers = "137.70.23.190","137.70.244.156","137.70.11.8"
		            break
	            }
	            "fr" {
		            $DNSServers = "137.70.23.189","137.70.23.189","137.70.244.31"
		            break
	            }
	            "ecom" {
		            switch -wildcard ($cluster) {
			            "visi*" {
				            $DNSServers = "172.21.1.22","172.21.113.13"
				            break
			            }
			            "wadc*" {
				            $DNSServers = "172.21.111.35","172.21.111.23"
				            break
			            }
		            }
	            }
	            "hcggse*" {
		            $DNSServers = "172.21.99.57","172.21.99.69"
		            break
	            }
	            "frse*" {
		            $DNSServers = "172.21.99.59","172.21.99.56"
		            break
	            }
	            "hcggpe*" {
		            $DNSServers = "172.21.104.6","172.21.104.7"
		            break
	            }
	            "frpe*" {
		            # frpe
		            $DNSServers = "172.21.104.12","172.21.104.5"
		            break
	            }
	            "egov*" {
					# FIX: not in prod yet?
					# no break, egovpe should match later
				}
                "hclib" {
					$DNSServers = "137.70.252.83","137.70.252.84"
					break
				}
                "egovpe" { # aka egov / egov.hennepinpe.us"
					$DNSServers = "172.21.104.40","172.21.104.39"
					break
				}
				"hclibpe" {
					# aka hclibpe.org
					$DNSServers = "172.21.104.10","172.21.104.11"
					break
				}
                default {
                    Throw "Unknown Domain: $domain. Unable to select DNS Servers"
                }
            }
        } # end if (! $DNSServers)
        
        # Set DN Path, DNS search list, full domain name, Localadmin username, & D drive size
        switch -wildcard ($domain){
	        "hcgg.*" {
		        $Path = "ou=Pre-ProdServers,dc=hcgg,dc=fr,dc=co,dc=hennepin,dc=mn,dc=us" 
		        $SearchList = "hcgg.fr.co.hennepin.mn.us,fr.co.hennepin.mn.us,co.hennepin.mn.us"
		        $domain = "hcgg.fr.co.hennepin.mn.us"
		        $username = "btg175" + "\" + $domain
		        if (!$ddrive) { $ddrive = 40 }
		        break
	        }
	        "hc_acct" {
		        $Path = "ou=Pre-ProdServers,dc=hcgg,dc=fr,dc=co,dc=hennepin,dc=mn,dc=us" 
		        $SearchList = "hcgg.fr.co.hennepin.mn.us,fr.co.hennepin.mn.us,co.hennepin.mn.us"
		        $domain = "hcgg.fr.co.hennepin.mn.us"
		        $username = "btg175" + "\" + $domain
		        if (!$ddrive) { $ddrive = 40 }
		        break
	        }
	        "fr" {
		        $Path = "CN=Computers,dc=fr,dc=co,dc=hennepin,dc=mn,dc=us" 
		        $SearchList = "fr.co.hennepin.mn.us,co.hennepin.mn.us"
		        $domain = "fr.co.hennepin.mn.us"
		        $unamepassprompt = 1
		        if (!$ddrive) { $ddrive = 40 }
		        break
	        }
	        "ecom" {
		        switch -wildcard ($cluster) {
			        "visi*" {
				        $Path = "ou=ProdServers,dc=ecom,dc=co,dc=hennepin,dc=mn,dc=us" 
				        $SearchList = ""
				        $domain = "ecom.co.hennepin.mn.us"
				        $unamepassprompt = 1
				        if (!$ddrive) { $ddrive = 40 }
				        break
			        }
			        "wadc*" {
				        $Path = "ou=ProdServers,dc=ecom,dc=co,dc=hennepin,dc=mn,dc=us" 
				        $SearchList = ""
				        $domain = "ecom.co.hennepin.mn.us"
				        $unamepassprompt = 1
				        if (!$ddrive) { $ddrive = 40 }
				        break
			        }
		        }
	        }
            "egov" {
		        $Path = "CN=Computers,dc=egov,dc=hennepin,dc=us" 
		        $SearchList = "egov.hennepin.us"
		        $domain = "egov.hennepin.us"
		        $username = "btl065" + "\" + $domain
		        if (!$ddrive) { $ddrive = 10 }
		        break
			}
			"hclib" {
		        $Path = "cn=computers,dc=hclib,dc=org" 
		        $SearchList = "hclib.org"
		        $domain = "hclib.org"
		        $username = "adteam" + "\" + $domain
		        if (!$ddrive) { $ddrive = 10 }
		        break
			}
	        "hcggse*" {
		        $Path = "ou=Pre-ProdServers,dc=hcggse,dc=frse,dc=co,dc=hennepin,dc=mn,dc=us" 
		        $SearchList = "hcggse.frse.co.hennepin.mn.us,frse.co.hennepin.mn.us,co.hennepin.mn.us"
		        $domain = "hcggse.frse.co.hennepin.mn.us"
		        $username = "btg175" + "\" + $domain
		        if (!$ddrive) { $ddrive = 10 }
		        $disktype = "Thin"
		        break
	        }
	        "frse*" {
		        $Path = "CN=Computers,dc=frse,dc=co,dc=hennepin,dc=mn,dc=us" 
		        $SearchList = "frse.co.hennepin.mn.us,co.hennepin.mn.us"
		        $domain = "frse.co.hennepin.mn.us"
		        $username = "btl065" + "\" + $domain
		        if (!$ddrive) { $ddrive = 10 }
		        $disktype = "Thin"
		        break
	        }
	        "hcggpe*" {
		        $Path = "ou=Pre-ProdServers,dc=hcggpe,dc=frpe,dc=co,dc=hennepin,dc=mn,dc=us" 
		        $SearchList = "hcggpe.frpe.co.hennepin.mn.us,frpe.co.hennepin.mn.us,pe.co.hennepin.mn.us"
		        $domain = "hcggpe.frpe.co.hennepin.mn.us"
		        $username = "btg175" + "\" + $domain
		        if (!$ddrive) { $ddrive = 20 }
		        break
	        }
	        "frpe*" {
		        # frpe
		        $Path = "CN=Computers,dc=frpe,dc=co,dc=hennepin,dc=mn,dc=us" 
		        $SearchList = "frpe.co.hennepin.mn.us,pe.co.hennepin.mn.us"
		        $domain = "frpe.co.hennepin.mn.us"
		        $username = "btl065" + "\" + $domain
		        if (!$ddrive) { $ddrive = 20 }
		        break
	        }
            "ecompe" {
		        $Path = "CN=Computers,dc=ecom,dc=co,dc=hennepinpe,dc=mn,dc=us" 
		        $SearchList = "ecom.co.hennepinpe.mn.us"
		        $domain = "ecom.co.hennepinpe.mn.us"
		        $username = "btl065" + "\" + $domain
		        if (!$ddrive) { $ddrive = 10 }
		        break
			}
            "egovpe" {
		        $Path = "CN=Computers,dc=egov,dc=hennepinpe,dc=us" 
		        $SearchList = "egov.hennepinpe.us"
		        $domain = "egov.hennepinpe.us"
		        $username = "btl065" + "\" + $domain
		        if (!$ddrive) { $ddrive = 10 }
		        break
			}
			"hclibpe" {
		        $Path = "CN=Computers,dc=hclibpe,dc=org" 
		        $SearchList = "hclibpe.org"
		        $domain = "hclibpe.org"
		        $username = "btl065" + "\" + $domain
		        if (!$ddrive) { $ddrive = 10 }
		        break
			}
            default {
                Throw "Unknown Domain: $domain. Unable to continue"
            }
        }

        Write-Verbose "Choosing System Disk Datastore"
        $sysdstore = $vmhost| get-datastore | where { $_.extensiondata.Summary.multiplehostaccess -eq $true `
                                        -and $_.type -eq "vmfs" `
                                        -and $_.name -like "*R-SYS*" } |
             sort-object FreeSpaceGB -descending | select-object -first 1
        Write-Verbose "System Datastore: $($sysdstore.name)"

        Write-Verbose "Choosing Data Disk Datastore"
        $datadstore = $vmhost| get-datastore | where { $_.extensiondata.Summary.multiplehostaccess -eq $true `
                                         -and $_.type -eq "vmfs" `
                                         -and ($_.name -like "*R-SATA*" -or $_.name -like "*R-DATA*" -or $_name -like "*R-SAS*")`
                                         -and ($_.name -notlike "*xen*")} |
             sort-object FreeSpaceGB -descending | select-object -first 1
        Write-Verbose "Data Datastore: $($datadstore.name)"

        Write-Verbose "Ensuring the chosen datastore is large enough"
        If ($datadstore.FreeSpaceGB -lt $ddrive){
            Throw "Unable to find a data store with sufficient free space for the requested data drive!"
            disconnect-viServer  -Force -Confirm:$false }

        # Calculate the Swap Drive Size
        $xdrive=[math]::Ceiling(($ram * 1.5) + 1)

        # There's no need to run Get-HCVMLanSettings if everything it returns has already been provided
        if (! $Gateway -and ! $SubnetMask -and ! $Network){
            $NetSettings = Get-HCVMLanSettings -IPAddress $ip
            If (! $NetSettings){
                Throw "Failed to get a valid return from Get-HCVMLanSettings for IPAddress $ip"
            }
        } 
        else {
            $NetSettings = [PSCustomObject]@{
                NetMask = $SubnetMask
                Gateway = $Gateway
                PortGroupLabel = $Network}
        }

        # fix: create domain joiner accounts to populate csuser and cspass
        $csuser = "Snoopy"
       
        if ((Get-OSCustomizationSpec).name -contains $template){
            $CustSpecisTemp = $false
            $custspec = Get-OSCustomizationSpec $template
            Set-OSCustomizationSpec $custspec -GuiRunOnce $launch
        } 
        else {
            $CustSpecisTemp = $true
            # We don't get to join the domain this way (yet)
            $custspecparam = @{ostype = "Windows"
                              name = "HCCustSpec"
                              domain = $domain
                              domainusername = $csuser
                              guirunonce = $launch
                              adminpassword = "Lanservices1"
                              autologoncount = 1
                              orgname = "Hennepin County"
                              fullname = "Hennepin County"
                              timezone = "020"
                              changesid = $true
                              type = 'NonPersistent'
                              }
            $custspec = new-oscustomizationspec @custspecparam
        }
        $NicSpecparam = @{IpMode = 'UseStaticIp'
                          IpAddress = $ip
                          SubnetMask = $netsettings.NetMask
                          DefaultGateway = $netsettings.Gateway
                          Dns = $DNSServers}

        Get-OSCustomizationSpec $custspec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping @NicSpecparam | Out-Null
	
        # parameters change from 4.1 to 5.1 -- kb and mb are obsolete in 5.1
        # 4.1: capacitykb, memorymb
        # 5.1: capacitygb, memorygb
        Write-Verbose "Creating New VM $vmname from template $template"

        $myVMparams = @{vmhost = $vmhost
                        name = $vmname
                        Template = $template
                        Datastore = $sysdstore
                        oscustomizationspec = $custspec
                        diskstorageformat = $disktype}
        # Write-Verbose $myVMparams

        $myvm = new-vm @myVMparams # -disktype flat is not a valid parameter for new-VM
        
        Write-Verbose "Adding D and X drives to new VM"
        if ($IsVC41) {
	        $xdrivekb = $ram * 1048576
	        $ddrivekb = $ddrive * 1048576
	        $rammb = $ram * 1024
	        new-harddisk -disktype flat -storageformat $disktype -capacitykb $ddrivekb -vm $myvm -Datastore $datadstore | Out-Null
	        new-harddisk -disktype flat -storageformat $disktype -capacitykb $xdrivekb -vm $myvm -Datastore $datadstore | Out-Null
	        $myvm | set-vm -MemoryMB $osrammb -confirm:$false
        } else {
	        new-harddisk -disktype flat -storageformat $disktype -capacitygb $ddrive -vm $myvm -Datastore $datadstore | Out-Null
	        new-harddisk -disktype flat -storageformat $disktype -capacitygb $xdrive -vm $myvm -Datastore $datadstore | Out-Null
	        $myvm | set-vm -MemoryGB $ram -confirm:$false | Out-Null
        }

        Write-Verbose "Setting CPU quantity"
        $myvm | set-vm -numcpu $cpu -confirm:$false | Out-Null

        Write-Verbose "Connecting NIC to the correct Portgroup"
        ## in set-networkadapter, -portgroup is the appropriate parameter when supplying a portgroup name.
        if ($domain -like "hcggse*" -or $cluster -like "*dmz*"){
        #this isn't a good selection method for the DMZ VMs.  perhaps on the structure of the network name
            $myvm | get-networkadapter | set-networkadapter -networkname $($netsettings.portgrouplabel) -startconnected:$true -confirm:$false
        }
        else {
            $myvm | get-networkadapter | set-networkadapter -Portgroup $($netsettings.portgrouplabel) -Confirm: $false | Out-Null
        }
       
        if ($CustSpecisTemp) {
            Write-verbose "removing OSCustomization spec $($custspec.name)"
            remove-oscustomizationspec -OSCustomizationSpec $custspec -Confirm:$false
        }
        
        Write-Verbose "Starting New VM"
        start-vm $myvm 
        
        Disconnect-VIServer -Force -Confirm:$false
        Write-Verbose "End of Process Block"
    } # if $snapin_loaded
} # Process Block
End {
    
    
    Set-PowerCLIConfiguration -DisplayDeprecationWarnings:$true -Confirm:$false | Out-Null
}
} # End Function New-HCVMVirtualMachine

Export-ModuleMember -Function Confirm-HCVMDataFile
Export-ModuleMember -Function Show-HCVMDefinitionPicker
Export-ModuleMember -Function Get-HCVMLanSettings
Export-ModuleMember -Function New-HCVMVirtualMachine
Export-ModuleMember -Variable HCVMVlanDataPreference