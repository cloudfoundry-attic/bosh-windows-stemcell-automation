. ./AutomationHelpers.ps1

Describe "CopyPSModules" {
    It "can copy PS Modules to target directory" {
        Mock Write-Log { }
        Mock Expand-Archive { }

        { CopyPSModules } | Should -Not -Throw

        Assert-MockCalled Expand-Archive -Times 1 -Scope It -ParameterFilter { $LiteralPath -eq ".\bosh-psmodules.zip" -and $DestinationPath -eq "C:\Program Files\WindowsPowerShell\Modules\" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Succesfully migrated Bosh Powershell modules to destination dir" }
    }

    It "fails gracefully when expanding archive fails" {
        Mock Expand-Archive { throw "Expand-Archive failed because something went wrong" }
        Mock Write-Log { }

        { CopyPSModules } | Should -Throw "Expand-Archive failed because something went wrong"

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Expand-Archive failed because something went wrong" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to copy Bosh Powershell Modules into destination dir. See 'c:\provision\log.log' for more info." }
    }
}

Describe "InstallCFFeatures" {
    It "executes the Install-CFFeatures2016 powershell cmdlet" {
        Mock Install-CFFeatures2016 { }
        Mock Write-Log { }
        Mock Restart-Computer { }

        { InstallCFFeatures } | Should -Not -Throw

        Assert-MockCalled Install-CFFeatures2016 -Times 1 -Scope It
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Successfully installed CF features" }
        Assert-MockCalled Restart-Computer -Times 1 -Scope It
    }

    It "fails gracefully when installing CF Features" {
        Mock Install-CFFeatures2016 { throw "Something terrible happened while attempting to install a CF feature" }
        Mock Write-Log { }
        Mock Restart-Computer { }

        { InstallCFFeatures } | Should -Throw "Something terrible happened while attempting to install a CF feature"

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Something terrible happened while attempting to install a CF feature" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to install the CF features. See 'c:\provision\log.log' for more info." }
        Assert-MockCalled Restart-Computer -Times 0 -Scope It
    }
}

Describe "Enable-HyperV" {
    It "executes the Enable-Hyper-V powershell cmdlet" {
        Mock Enable-Hyper-V { }
        Mock Write-Log { }

        { Enable-HyperV } | Should -Not -Throw

        Assert-MockCalled Enable-Hyper-V -Times 1 -Scope It
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Successfully enabled HyperV" }
    }

    It "fails gracefully when enabling Hyper-V" {
        Mock Enable-Hyper-V { throw "unable to comply" }
        Mock Write-Log { }

        { Enable-HyperV } | Should -Throw "unable to comply"

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "unable to comply" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to enable HyperV. See 'c:\provision\log.log' for more info." }
    }
}

Describe "InstallCFCell" {
    It "executes the Protect-CFCell powershell cmdlet" {
        Mock Protect-CFCell { }
        Mock Write-Log { }

        { InstallCFCell } | Should -Not -Throw

        Assert-MockCalled Protect-CFCell -Times 1
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Succesfully ran Protect-CFCell" }
    }

    It "fails gracefully when Protect-CFCell powershell cmdlet fails" {
        Mock Protect-CFCell { throw "Something terrible happened while attempting to execute Protect-CFCell" }
        Mock Write-Log { }

        { InstallCFCell } | Should -Throw "Something terrible happened while attempting to execute Protect-CFCell"

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Something terrible happened while attempting to execute Protect-CFCell" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to execute Protect-CFCell powershell cmdlet. See 'c:\provision\log.log' for more info." }
    }
}

Describe "InstallBoshAgent" {
    It "executes the Install-Agent powershell cmdlet" {
        Mock Install-Agent { }
        Mock Write-Log { }

        { InstallBoshAgent } | Should -Not -Throw


        Assert-MockCalled Install-Agent -Times 1 -Scope It -ParameterFilter { $IaaS -eq "vsphere" -and $agentZipPath -eq ".\agent.zip" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Bosh agent successfully installed" }
    }

    It "fails gracefully when Install-Agent powershell cmdlet fails" {
        Mock Install-Agent { throw "Something terrible happened while attempting to execute Install-Agent" }
        Mock Write-Log { }

        { InstallBoshAgent } | Should -Throw "Something terrible happened while attempting to execute Install-Agent"

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Something terrible happened while attempting to execute Install-Agent" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to execute Install-Agent powershell cmdlet. See 'c:\provision\log.log' for more info." }
    }
}

Describe "InstallOpenSSH" {
    It "executes the Install-SSHD powershell cmdlet" {
        Mock Install-SSHD { }
        Mock Write-Log { }

        { InstallOpenSSH } | Should -Not -Throw


        Assert-MockCalled Install-SSHD -Times 1 -Scope It -ParameterFilter { $SSHZipFile -eq ".\OpenSSH-Win64.zip" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "OpenSSH successfully installed" }
    }

    It "fails gracefully when Install-SSHD powershell cmdlet fails" {
        Mock Install-SSHD { throw "Something terrible happened while attempting to execute Install-SSHD" }
        Mock Write-Log { }

        { InstallOpenSSH } | Should -Throw "Something terrible happened while attempting to execute Install-SSHD"

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Something terrible happened while attempting to execute Install-SSHD" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to execute Install-SSHD powershell cmdlet. See 'c:\provision\log.log' for more info." }
    }
}

Describe "CleanUpVM" {
    It "executes the Optimize-Disk and Compress-Disk powershell cmdlet" {
        Mock Optimize-Disk { }
        Mock Compress-Disk { }
        Mock Write-Log { }

        { CleanUpVM } | Should -Not -Throw

        Assert-MockCalled Optimize-Disk -Times 1 -Scope It
        Assert-MockCalled Compress-Disk -Times 1 -Scope It
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Successfully cleaned up the VM's disk" }
    }

    It "fails gracefully when Optimize-Disk powershell cmdlet fails" {
        Mock Optimize-Disk { throw "Something terrible happened while attempting to execute Optimize-Disk" }
        Mock Compress-Disk { }
        Mock Write-Log { }

        { CleanUpVM } | Should -Throw "Something terrible happened while attempting to execute Optimize-Disk"

        Assert-MockCalled Optimize-Disk -Times 1 -Scope It
        Assert-MockCalled Compress-Disk -Times 0 -Scope It

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Something terrible happened while attempting to execute Optimize-Disk" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to clean up the VM's disk. See 'c:\provision\log.log' for more info." }
    }

    It "fails gracefully when Compress-Disk powershell cmdlet fails" {
        Mock Optimize-Disk { }
        Mock Compress-Disk { throw "Something terrible happened while attempting to execute Compress-Disk" }
        Mock Write-Log { }

        { CleanUpVM } | Should -Throw "Something terrible happened while attempting to execute Compress-Disk"

        Assert-MockCalled Optimize-Disk -Times 1 -Scope It
        Assert-MockCalled Compress-Disk -Times 1 -Scope It

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Something terrible happened while attempting to execute Compress-Disk" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to clean up the VM's disk. See 'c:\provision\log.log' for more info." }
    }
}

Describe "SysprepVM" {
    It "copies LGPO to the correct destination and executes the Invoke-Sysprep powershell cmdlet" {
        Mock Expand-Archive { }
        Mock Invoke-Sysprep { }
        Mock GenerateRandomPassword { "SomeRandomPassword" }
        Mock Write-Log { }

        { SysprepVM } | Should -Not -Throw

        Assert-MockCalled Expand-Archive -Times 1 -Scope It -ParameterFilter { $LiteralPath -eq ".\LGPO.zip" -and $DestinationPath -eq "C:\Windows\" }
        Assert-MockCalled GenerateRandomPassword -Times 1 -Scope It
        Assert-MockCalled Invoke-Sysprep -Times 1 -Scope It -ParameterFilter { $IaaS -eq "vsphere" -and $NewPassword -eq "SomeRandomPassword" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Successfully migrated LGPO to destination dir" }
    }

    It "executes the Invoke-Sysprep powershell cmdlet with owner parameter set when an owner string is provided" {
        Mock Expand-Archive { }
        Mock Invoke-Sysprep { }
        Mock GenerateRandomPassword { "SomeRandomPassword" }
        Mock Write-Log { }

        { SysprepVM -Owner "some owner" } | Should -Not -Throw

        Assert-MockCalled Invoke-Sysprep -Times 1 -Scope It -ParameterFilter { $IaaS -eq "vsphere" -and $NewPassword -eq "SomeRandomPassword" -and $Owner -eq "some owner" -and $Organization -eq "" }
    }

    It "executes the Invoke-Sysprep powershell cmdlet with organization parameter set when an organization string is provided" {
        Mock Expand-Archive { }
        Mock Invoke-Sysprep { }
        Mock GenerateRandomPassword { "SomeRandomPassword" }
        Mock Write-Log { }

        { SysprepVM -Organization "some org" } | Should -Not -Throw

        Assert-MockCalled Invoke-Sysprep -Times 1 -Scope It -ParameterFilter { $IaaS -eq "vsphere" -and $NewPassword -eq "SomeRandomPassword" -and $Organization -eq "some org" -and $Owner -eq "" }
    }

    It "executes the Invoke-Sysprep powershell cmdlet with owner parameter set when an organization string has line breaks" {
        Mock Expand-Archive { }
        Mock Invoke-Sysprep { }
        Mock GenerateRandomPassword { "SomeRandomPassword" }
        Mock Write-Log { }

        { SysprepVM -Owner "some `r`n org" } | Should -Not -Throw

        Assert-MockCalled Invoke-Sysprep -Times 1 -Scope It -ParameterFilter { $IaaS -eq "vsphere" -and $NewPassword -eq "SomeRandomPassword" -and $Owner -eq "some `r`n org" -and $Organization -eq "" }
    }

    It "executes the Invoke-Sysprep powershell cmdlet with owner & organization parameter set when an owner & organization string is provided" {
        Mock Expand-Archive { }
        Mock Invoke-Sysprep { }
        Mock GenerateRandomPassword { "SomeRandomPassword" }
        Mock Write-Log { }

        { SysprepVM -Owner "some owner" -Organization "some org" } | Should -Not -Throw

        Assert-MockCalled Invoke-Sysprep -Times 1 -Scope It -ParameterFilter { $IaaS -eq "vsphere" -and $NewPassword -eq "SomeRandomPassword" -and $Owner -eq "some owner" -and $Organization -eq "some org" }
    }


    It "fails gracefully when Expand-Archive powershell cmdlet fails" {
        Mock Expand-Archive { throw "Expand-Archive failed because something went wrong" }
        Mock Invoke-Sysprep { }
        Mock GenerateRandomPassword { "SomeRandomPassword" }
        Mock Write-Log { }

        { SysprepVM } | Should -Throw "Expand-Archive failed because something went wrong"

        Assert-MockCalled Expand-Archive -Times 1 -Scope It -ParameterFilter { $LiteralPath -eq ".\LGPO.zip" -and $DestinationPath -eq "C:\Windows\" }
        Assert-MockCalled GenerateRandomPassword -Times 0 -Scope It
        Assert-MockCalled Invoke-Sysprep -Times 0 -Scope It -ParameterFilter { $IaaS -eq "vsphere" -and $NewPassword -eq "SomeRandomPassword" }

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Expand-Archive failed because something went wrong" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to Sysprep the VM's. See 'c:\provision\log.log' for more info." }
    }

    It "fails gracefully when Invoke-Sysprep powershell cmdlet fails" {
        Mock Expand-Archive { }
        Mock Invoke-Sysprep { throw "Invoke-Sysprep failed because something went wrong" }
        Mock GenerateRandomPassword { "SomeRandomPassword" }
        Mock Write-Log { }

        { SysprepVM } | Should -Throw "Invoke-Sysprep failed because something went wrong"

        Assert-MockCalled Expand-Archive -Times 1 -Scope It -ParameterFilter { $LiteralPath -eq ".\LGPO.zip" -and $DestinationPath -eq "C:\Windows\" }
        Assert-MockCalled GenerateRandomPassword -Times 1 -Scope It
        Assert-MockCalled Invoke-Sysprep -Times 1 -Scope It -ParameterFilter { $IaaS -eq "vsphere" -and $NewPassword -eq "SomeRandomPassword" }

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Invoke-Sysprep failed because something went wrong" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to Sysprep the VM's. See 'c:\provision\log.log' for more info." }
    }

    It "fails gracefully when GenerateRandomPassword function fails" {
        Mock Expand-Archive { }
        Mock Invoke-Sysprep { }
        Mock GenerateRandomPassword { throw "GenerateRandomPassword failed because something went wrong" }
        Mock Write-Log { }

        { SysprepVM } | Should -Throw "GenerateRandomPassword failed because something went wrong"

        Assert-MockCalled Expand-Archive -Times 1 -Scope It -ParameterFilter { $LiteralPath -eq ".\LGPO.zip" -and $DestinationPath -eq "C:\Windows\" }
        Assert-MockCalled GenerateRandomPassword -Times 1 -Scope It
        Assert-MockCalled Invoke-Sysprep -Times 0 -Scope It

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "GenerateRandomPassword failed because something went wrong" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to Sysprep the VM's. See 'c:\provision\log.log' for more info." }
    }

    It "doesn't generate a new password when -SkipRandomPassword set to true" {
        Mock Expand-Archive { }
        Mock Write-Log { }
        Mock Invoke-Sysprep { }

        { SysprepVM -SkipRandomPassword $True} | Should -Not -Throw

        Assert-MockCalled Invoke-Sysprep -Times 1 -Scope It -ParameterFilter { $IaaS -eq "vsphere" -and $NewPassword -eq $null }
    }
}

Describe "GenerateRandomPassword" {

    It "generates a valid password" {
        Mock Get-Random { "changeMe123!".ToCharArray() }
        Mock Valid-Password { $True }
        Mock Write-Log{ }
        $result = ""
        { GenerateRandomPassword | Set-Variable -Name "result" -Scope 1 } | Should -Not -Throw
        $result | Should -BeExactly "changeMe123!"

        Assert-MockCalled Get-Random -Times 1 -Scope It
        Assert-MockCalled Valid-Password -Times 1 -Scope It -ParameterFilter { $Password -eq "changeMe123!" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Successfully generated password" }
    }

    It "fails to generate a valid password after 200 tries" {
        Mock Get-Random { "changeMe123!".ToCharArray() }
        Mock Valid-Password { $False }
        Mock Write-Log{ }

        { GenerateRandomPassword } | Should -Throw "Unable to generate a valid password after 200 attempts"

        Assert-MockCalled Get-Random -Times 200 -Scope It
        Assert-MockCalled Valid-Password -Times 200 -Scope It -ParameterFilter { $Password -eq "changeMe123!" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to generate password after 200 attempts" }
    }
}

Describe "Valid-Password" {

    Context "returns true with a valid password input of at least 8 characters" {
        It "that contains at least 1 digit, 1 special, and 1 lower case character" {
            Valid-Password "changeme123!" | Should -Be $True
        }

        It "that contains at least 1 digit, 1 special, and 1 upper case character" {
            Valid-Password "CHANGEME123!" | Should -Be $True
        }

        It "that contains at least 1 digit, 1 upper case, and 1 lower case character" {
            Valid-Password "Changeme123" | Should -Be $True
        }

        It "that contains at least 1 special, 1 upper case, and 1 lower case character" {
            Valid-Password "Changeme!" | Should -Be $True
        }
    }

    Context "returns false with a invalid password input" {
        It "that contains less than 8 characters" {
            Valid-Password "a" | Should -Be $false
        }

        It "that contains only upper and lower case characters" {
            Valid-Password "Changemenow" | Should -Be $false
        }

        It "that contains only digits and special characters" {
            Valid-Password "123!456*789?" | Should -Be $false
        }

        It "that contains only digits and upper case characters" {
            Valid-Password "CHANGE123ME" | Should -Be $false
        }

        It "that contains only lower case and special characters" {
            Valid-Password "qwerty!@#$%%" | Should -Be $false
        }

        It "that contains an invalid character" {
            Valid-Password "JoyeuxNoël123!" | Should -Be $false
        }

        It "that contains a whitespace character" {
            Valid-Password "JoyeuxNoel 123!" | Should -Be $false
        }
    }
}

Describe "Is-Special" {
    It "returns true when given a valid special character" {
        $CharList = "!`"#$%&'()*+,-./:;<=>?@[\]^_``{|}~".ToCharArray()
        foreach ($c in $CharList)
        {
            Is-Special $c | Should -Be $true
        }
    }

    It "returns false when given an alpha numeric characters" {
        Is-Special "a" | Should -Be $False
        Is-Special "5" | Should -Be $False
        Is-Special "T" | Should -Be $False
    }

    It "returns false when given whitespace character" {
        Is-Special " " | Should -Be $False
    }
}

function GenerateDepJson
{
    param ([parameter(Mandatory = $true)] [string]$file1Sha,
        [parameter(Mandatory = $true)] [string]$file2Sha,
        [parameter(Mandatory = $true)] [string]$file3Sha
    )

    return "{""file1.zip"":{""sha"":""$file1Sha"",""version"":""1.0""},""file2.zip"":{""sha"":""$file2Sha"",""version"":""1.0-alpha""},""file3.exe"":{""sha"":""$file3Sha"",""version"":""3.0""}}"
}

Describe "Check-Dependencies" {
    BeforeEach {
        Mock Write-Log { }

        $file1Hash = @{
            Algorithm = "SHA256"
            Hash = "hashOne"
            Path = "$PSScriptRoot/file1.zip"
        }
        $file2Hash = @{
            Algorithm = "SHA256"
            Hash = "hashTwo"
            Path = "$PSScriptRoot/file2.zip"
        }
        $file3Hash = @{
            Algorithm = "SHA256"
            Hash = "hashThree"
            Path = "$PSScriptRoot/file3.exe"
        }

        Mock Get-FileHash { New-Object PSObject -Property $file1Hash } -ParameterFilter { $Path -cmatch "$PSScriptRoot/file1.zip" }
        Mock Get-FileHash { New-Object PSObject -Property $file2Hash } -ParameterFilter { $Path -cmatch "$PSScriptRoot/file2.zip" }
        Mock Get-FileHash { New-Object PSObject -Property $file3Hash } -ParameterFilter { $Path -cmatch "$PSScriptRoot/file3.exe" }

        Mock Test-Path { $true } -ParameterFilter { $Path -cmatch "$PSScriptRoot/file1.zip" }
        Mock Test-Path { $true } -ParameterFilter { $Path -cmatch "$PSScriptRoot/file2.zip" }
        Mock Test-Path { $true } -ParameterFilter { $Path -cmatch "$PSScriptRoot/file3.exe" }

        #We specify when to throw the exception to prevent other test from being polluted when calling Convert-FromJson
        Mock ConvertFrom-Json { throw "Invalid JSON primitive: bad-json-format" } -ParameterFilter { $InputObject -match "bad-json-format" }
    }


    It "successfully checks all required files are available and have the correct SHAs" {
        Mock Get-Content { GenerateDepJson "hashOne" "hashTwo" "hashThree" }

        { Check-Dependencies } | Should -Not -Throw

        Assert-MockCalled Get-Content -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/deps.json" }

        Assert-MockCalled Get-FileHash -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file1.zip" }
        Assert-MockCalled Get-FileHash -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file2.zip" }
        Assert-MockCalled Get-FileHash -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file3.exe" }

        Assert-MockCalled Test-Path -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file1.zip" }
        Assert-MockCalled Test-Path -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file2.zip" }
        Assert-MockCalled Test-Path -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file3.exe" }

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Found all dependencies" }
    }

    Context "fails gracefully if the dependency file" {
        It "is not present" {
            Mock Get-Content { throw "File not found" }

            { Check-Dependencies } | Should -Throw "File not found"

            Assert-MockCalled Get-Content -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/deps.json" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "File not found" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate required dependencies. See 'c:\provision\log.log' for more info." }

        }

        It "is empty" {
            Mock Get-Content { "" }

            { Check-Dependencies } | Should -Throw "Dependency file is empty"

            Assert-MockCalled Get-Content -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/deps.json" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Dependency file is empty" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate required dependencies. See 'c:\provision\log.log' for more info." }
        }

        It "contains an empty json object" {
            Mock Get-Content { "{}" }

            { Check-Dependencies } | Should -Throw "Dependency file is empty"

            Assert-MockCalled Get-Content -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/deps.json" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Dependency file is empty" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate required dependencies. See 'c:\provision\log.log' for more info." }
        }

        It "content is badly formatted" {
            Mock Get-Content { "bad-json-format" }

            { Check-Dependencies } | Should -Throw "Invalid JSON primitive: bad-json-format"

            Assert-MockCalled Get-Content -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/deps.json" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Invalid JSON primitive: bad-json-format" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate required dependencies. See 'c:\provision\log.log' for more info." }

        }
    }

    Context "fails gracefully when checking file dependencies" {
        It "when one or more are not found" {
            Mock Get-Content { GenerateDepJson "hashOne" "hashTwo" "hashThree" }
            Mock Test-Path { $false } -ParameterFilter { $Path -cmatch "$PSScriptRoot/file2.zip" }
            Mock Test-Path { $false } -ParameterFilter { $Path -cmatch "$PSScriptRoot/file3.exe" }

            { Check-Dependencies } | Should -Throw "One or more files are corrupted or missing."

            Assert-MockCalled Get-Content -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/deps.json" }

            Assert-MockCalled Get-FileHash -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file1.zip" }
            Assert-MockCalled Get-FileHash -Times 0 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file2.zip" }
            Assert-MockCalled Get-FileHash -Times 0 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file3.exe" }

            Assert-MockCalled Test-Path -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file1.zip" }
            Assert-MockCalled Test-Path -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file2.zip" }
            Assert-MockCalled Test-Path -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file3.exe" }

            Assert-MockCalled Write-Log -Times 0 -Scope It -ParameterFilter { $Message -like "$PSScriptRoot/file1.zip *" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -cmatch "$PSScriptRoot/file2.zip is required but was not found" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -cmatch "$PSScriptRoot/file3.exe is required but was not found" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate required dependencies. See 'c:\provision\log.log' for more info." }
        }

        It "when one or more file hashes do not match" {
            Mock Get-Content { GenerateDepJson "hashOne" "badhash2" "badhash3" }

            { Check-Dependencies } | Should -Throw "One or more files are corrupted or missing."

            Assert-MockCalled Get-Content -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/deps.json" }

            Assert-MockCalled Get-FileHash -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file1.zip" }
            Assert-MockCalled Get-FileHash -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file2.zip" }
            Assert-MockCalled Get-FileHash -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file3.exe" }

            Assert-MockCalled Test-Path -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file1.zip" }
            Assert-MockCalled Test-Path -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file2.zip" }
            Assert-MockCalled Test-Path -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file3.exe" }

            Assert-MockCalled Write-Log -Times 0 -Scope It -ParameterFilter { $Message -like "$PSScriptRoot/file1.zip *" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -cmatch "$PSScriptRoot/file2.zip does not have the correct hash" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -cmatch "$PSScriptRoot/file3.exe does not have the correct hash" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate required dependencies. See 'c:\provision\log.log' for more info." }
        }

        It "when one file hash does not match and another file is missing " {
            Mock Test-Path { $False } -ParameterFilter { $Path -cmatch "$PSScriptRoot/file3.exe" }
            Mock Get-Content { GenerateDepJson "hashOne" "badhash2" "hashThree" }

            { Check-Dependencies } | Should -Throw "One or more files are corrupted or missing."

            Assert-MockCalled Get-Content -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/deps.json" }

            Assert-MockCalled Get-FileHash -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file1.zip" }
            Assert-MockCalled Get-FileHash -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file2.zip" }
            Assert-MockCalled Get-FileHash -Times 0 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file3.exe" }

            Assert-MockCalled Test-Path -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file1.zip" }
            Assert-MockCalled Test-Path -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file2.zip" }
            Assert-MockCalled Test-Path -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/file3.exe" }

            Assert-MockCalled Write-Log -Times 0 -Scope It -ParameterFilter { $Message -like "$PSScriptRoot/file1.zip *" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -cmatch "$PSScriptRoot/file2.zip does not have the correct hash" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -cmatch "$PSScriptRoot/file3.exe is required but was not found" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate required dependencies. See 'c:\provision\log.log' for more info." }
        }
    }
}

Describe "Validate-OSVersion" {
    BeforeEach {
        Mock Write-Log { }
    }

    It "fails gracefully when the OS major version doesn't match" {
        Mock Get-OSVersionString { "14.0.16299.0" }

        { Validate-OSVersion } | Should -Throw "OS Version Mismatch: Please use Windows Server 2019 or Windows Server 2016, Version 1709 or 1803"

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "OS Version Mismatch: Please use Windows Server 2019 or Windows Server 2016, Version 1709 or 1803" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate the OS version. See 'c:\provision\log.log' for more info." }
        Assert-MockCalled Get-OSVersionString -Times 1 -Scope It
    }

    It "fails gracefully when the OS minor version doesn't match" {
        Mock Get-OSVersionString { "10.5.16299.0" }

        { Validate-OSVersion } | Should -Throw "OS Version Mismatch: Please use Windows Server 2019 or Windows Server 2016, Version 1709"

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "OS Version Mismatch: Please use Windows Server 2019 or Windows Server 2016, Version 1709 or 1803" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate the OS version. See 'c:\provision\log.log' for more info." }
        Assert-MockCalled Get-OSVersionString -Times 1 -Scope It

    }

    It "fails gracefully when the OS build version doesn't match" {
        Mock Get-OSVersionString { "10.0.12345.0" }

        { Validate-OSVersion } | Should -Throw "OS Version Mismatch: Please use Windows Server 2019 or Windows Server 2016, Version 1709"

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "OS Version Mismatch: Please use Windows Server 2019 or Windows Server 2016, Version 1709 or 1803" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate the OS version. See 'c:\provision\log.log' for more info." }
        Assert-MockCalled Get-OSVersionString -Times 1 -Scope It
    }

    It "successfully validates the OS when it is Windows Server 1709" {
        Mock Get-OSVersionString { "10.0.16299.0" }

        { Validate-OSVersion } | Should -Not -Throw

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Found correct OS version: Windows Server 2016, Version 1709" }
        Assert-MockCalled Get-OSVersionString -Times 1 -Scope It
}

    It "successfully validates the OS when it is Windows Server 1803" {
        Mock Get-OSVersionString { "10.0.17134.2761" }

        { Validate-OSVersion } | Should -Not -Throw

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Found correct OS version: Windows Server 2016, Version 1803" }
        Assert-MockCalled Get-OSVersionString -Times 1 -Scope It
    }

    It "successfully validates the OS when it is Windows Server 2019" {
        Mock Get-OSVersionString { "10.0.17763.2761" }

        { Validate-OSVersion } | Should -Not -Throw

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Found correct OS version: Windows Server 2019" }
        Assert-MockCalled Get-OSVersionString -Times 1 -Scope It
    }

    It "fails gracefully when an exception is received when getting OS version" {
        Mock Get-OSVersionString { throw "Could not fetch OS version" }
        Mock Write-Log

        { Validate-OSVersion } | Should -Throw "Could not fetch OS version"

        Assert-MockCalled Get-OSVersionString -Times 1 -Scope It

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -cmatch "Could not fetch OS version" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate the OS version. See 'c:\provision\log.log' for more info." }
    }
}


Describe "DeleteScheduledTask" {
    BeforeEach {
        $scheduledTask1 = New-Object PSObject -Property @{
            TaskName = "Task01"
        }
        $boshScheduledTask = New-Object PSObject -Property @{
            TaskName = "BoshCompleteVMPrep"
        }
        $scheduledtask2 = New-Object PSObject -Property @{
            TaskName = "Unknown task"
        }
        $scheduledtask3 = New-Object PSObject -Property @{
            TaskName = "Another task"
        }
        Mock Write-Log { }
        Mock Unregister-ScheduledTask { }
        Mock Get-ScheduledTask { @($scheduledTask1,$boshScheduledTask,$scheduledTask2,$scheduledTask3) }

    }
    It "successfully delete the Bosh scheduled task, when the task has been registered" {
        { DeleteScheduledTask } | Should -Not -Throw

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -cmatch "Successfully deleted the 'BoshCompleteVMPrep' scheduled task" }

        Assert-MockCalled Get-ScheduledTask -Times 1 -Scope It
        Assert-MockCalled Unregister-ScheduledTask -Times 1 -Scope It -ParameterFilter { $TaskName -cmatch "BoshCompleteVMPrep" -and $PSBoundParameters['Confirm'] -eq $false }
    }

    It "does nothing if the Bosh scheduled task has not been registered" {
        Mock Get-ScheduledTask { @($scheduledTask1,$scheduledTask2,$scheduledTask3) }
        { DeleteScheduledTask } | Should -Not -Throw

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -cmatch "BoshCompleteVMPrep schedule task was not registered" }

        Assert-MockCalled Get-ScheduledTask -Times 1 -Scope It
        Assert-MockCalled Unregister-ScheduledTask -Times 0 -Scope It -ParameterFilter { $TaskName -cmatch "BoshCompleteVMPrep" -and $PSBoundParameters['Confirm'] -eq $false }
    }

    It "fails gracefully if the registered Bosh scheduled task was not unregistered" {
        Mock Unregister-ScheduledTask { throw "Could not unregister task" }

        { DeleteScheduledTask } | Should -Throw "Could not unregister task"

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -cmatch "Could not unregister task" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to unregister the BoshCompleteVMPrep scheduled task. See 'c:\provision\log.log' for more info." }

        Assert-MockCalled Get-ScheduledTask -Times 1 -Scope It
        Assert-MockCalled Unregister-ScheduledTask -Times 1 -Scope It -ParameterFilter { $TaskName -cmatch "BoshCompleteVMPrep" -and $PSBoundParameters['Confirm'] -eq $false }
    }
}

Describe "Create-VMPrepTaskAction" {
    It "Sucessfully creates a TaskAction with owner and organization arguments" {
        $taskAction = $null
        $goldenArguments = "-NoExit -File ""$PSScriptRoot\Complete-VMPrep.ps1"" -Organization ""Pivotal Cloud Foundry"" -Owner ""Pivotal User"""

        { Create-VMPrepTaskAction -Owner "Pivotal User" -Organization "Pivotal Cloud Foundry" | Set-Variable -Name "taskAction" -Scope 1 } | Should -Not -Throw

        $taskAction.Arguments | Should -eq $goldenArguments
    }

    It "Sucessfully creates a TaskAction with SkipRandomPassword" {
        $taskAction = $null
        $goldenArguments = "-NoExit -File ""$PSScriptRoot\Complete-VMPrep.ps1"" -SkipRandomPassword"

        { Create-VMPrepTaskAction -SkipRandomPassword | Set-Variable -Name "taskAction" -Scope 1 } | Should -Not -Throw

        $taskAction.Arguments | Should -eq $goldenArguments
    }
}

Describe "Set-RegKeys" {
    It "Successfully sets the registry keys." {
        Mock New-ItemProperty{ }
	Mock Test-Path { $True }
        { Set-RegKeys } | Should -Not -Throw
        Assert-MockCalled New-ItemProperty -ParameterFilter{ $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat' -and $Value -eq 0 -and $Name -eq 'cadca5fe-87d3-4b96-b7fb-a231484277cc' }
        Assert-MockCalled New-ItemProperty -ParameterFilter{ $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization' -and $Value -eq 1.0 -and $Name -eq 'MinVmVersionForCpuBasedMitigations' }
        Assert-MockCalled New-ItemProperty -ParameterFilter{ $Path -eq 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -and $Value -eq 3 -and $Name -eq 'FeatureSettingsOverrideMask' }
        Assert-MockCalled New-ItemProperty -ParameterFilter{ $Path -eq 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -and $Value -eq 72 -and $Name -eq 'FeatureSettingsOverride' }
    }

    It "Successfully sets the registry keys including non-existing one. " {
	Mock New-Item { }
	Mock New-ItemProperty{ }
	Mock Test-Path { $False }
        { Set-RegKeys } | Should -Not -Throw
        Assert-MockCalled New-Item -ParameterFilter{ $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat' } -Times 1
        Assert-MockCalled New-ItemProperty -ParameterFilter{ $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat' -and $Value -eq 0 -and $Name -eq 'cadca5fe-87d3-4b96-b7fb-a231484277cc' }
        Assert-MockCalled New-ItemProperty -ParameterFilter{ $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization' -and $Value -eq 1.0 -and $Name -eq 'MinVmVersionForCpuBasedMitigations' }
        Assert-MockCalled New-ItemProperty -ParameterFilter{ $Path -eq 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -and $Value -eq 3 -and $Name -eq 'FeatureSettingsOverrideMask' }
        Assert-MockCalled New-ItemProperty -ParameterFilter{ $Path -eq 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -and $Value -eq 72 -and $Name -eq 'FeatureSettingsOverride' }
    }
}

Describe "Install-SecurityPoliciesAndRegistries" {

    BeforeEach {
        function Set-InternetExplorerRegistries{ }
    }

    It "executes the Set-InternetExplorerRegistries powershell cmdlet if the os verison is 2019" {
        $osVersion2019 = "10.0.17763.0"
        Mock Set-InternetExplorerRegistries { }
        Mock Write-Log { }
        Mock Get-OSVersionString { $osVersion2019 }

        { Install-SecurityPoliciesAndRegistries } | Should -Not -Throw

        Assert-MockCalled Set-InternetExplorerRegistries -Times 1 -Scope It
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Succesfully ran Set-InternetExplorerRegistries" }
    }

    It "does not execute the Set-InternetExplorerRegistries powershell cmdlet if the os version is not 2019" {
        Mock Set-InternetExplorerRegistries { }
        Mock Write-Log { }
        Mock Get-OSVersionString { "NOT_2019" }

        { Install-SecurityPoliciesAndRegistries } | Should -Not -Throw

        Assert-MockCalled Set-InternetExplorerRegistries -Times 0 -Scope It
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Did not run Set-InternetExplorerRegistries because OS version was not 2019" }

    }

    It "fails gracefully when Set-InternetExplorerRegistries powershell cmdlet fails" {
        $osVersion2019 = "10.0.17763.0"
        Mock Get-OSVersionString { $osVersion2019 }
        Mock Set-InternetExplorerRegistries { throw "Something terrible happened while attempting to execute Set-InternetExplorerRegistries" }
        Mock Write-Log { }

        { Install-SecurityPoliciesAndRegistries  } | Should -Throw "Something terrible happened while attempting to execute Set-InternetExplorerRegistries"

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Something terrible happened while attempting to execute Set-InternetExplorerRegistries" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to execute Set-InternetExplorerRegistries powershell cmdlet. See 'c:\provision\log.log' for more info." }
    }

}

function CreateFakeOpenSSHZip
{
    param([string]$dir, [string]$installScriptSpyStatus, [string]$fakeZipPath)

    mkdir "$dir\OpenSSH-Win64"
    $installSpyBehavior = "echo installed > $installScriptSpyStatus"
    echo $installSpyBehavior > "$dir\OpenSSH-Win64\install-sshd.ps1"
    echo "fake sshd" > "$dir\OpenSSH-Win64\sshd.exe"

    Compress-Archive -Force -Path "$dir\OpenSSH-Win64" -DestinationPath $fakeZipPath
}

Describe "Enable-SSHD" {
    BeforeEach {
        Mock Set-Service { }
        Mock Run-LGPO { }

        $guid = $( New-Guid ).Guid
        $TMP_DIR = "$env:TEMP\BOSH.SSH.Tests-$guid"

        $FAKE_ZIP = "$TMP_DIR\OpenSSH-TestFake.zip"
        $INSTALL_SCRIPT_SPY_STATUS = "$TMP_DIR\install-script-status"

        CreateFakeOpenSSHZip -dir $TMP_DIR -installScriptSpyStatus $INSTALL_SCRIPT_SPY_STATUS -fakeZipPath $FAKE_ZIP

        mkdir -p "$TMP_DIR\Windows\Temp"
        echo "fake LGPO" > "$TMP_DIR\Windows\LGPO.exe"

        $ORIGINAL_WINDIR = $env:WINDIR
        $env:WINDIR = "$TMP_DIR\Windows"

        $ORIGINAL_PROGRAMDATA = $env:ProgramData
        $env:PROGRAMDATA = "$TMP_DIR\ProgramData"
  }

    AfterEach {
        Remove-Item $TMP_DIR -Recurse -ErrorAction Ignore
        $env:WINDIR = $ORIGINAL_WINDIR
        $env:PROGRAMDATA = $ORIGINAL_PROGRAMDATA
    }

    It "sets the startup type of sshd to automatic" {
        Mock Set-Service { } -Verifiable  -ParameterFilter { $Name -eq "sshd" -and $StartupType -eq "Automatic" }

        Enable-SSHD -SSHZipFile $FAKE_ZIP

        Assert-VerifiableMock
    }

    It "sets the startup type of ssh-agent to automatic" {
        Mock Set-Service { } -Verifiable  -ParameterFilter { $Name -eq "ssh-agent" -and $StartupType -eq "Automatic" }

        Enable-SSHD -SSHZipFile $FAKE_ZIP

        Assert-VerifiableMock
    }

    It "sets up firewall when ssh not already set up" {
        Mock Get-NetFirewallRule {
            return [ordered]@{
                "Name" = "{3c06039b-ece1-4da3-8ece-255894975894}"
                "DisplayName" = "NTP"
                "Description" = ""
                "DisplayGroup" = ""
                "Group" = ""
                "Enabled" = "True"
                "Profile" = "Any"
                "Platform" = "{}"
                "Direction" = "Outbound"
                "Action" = "Allow"
                "EdgeTraversalPolicy" = "Block"
                "LooseSourceMapping" = "False"
                "LocalOnlyMapping" = "False"
                "Owner" = ""
                "PrimaryStatus" = "OK"
                "Status" = "The rule was parsed successfully from the store. (65536)"
                "EnforcementStatus" = "NotApplicable"
                "PolicyStoreSource" = "PersistentStore"
                "PolicyStoreSourceType" = "Local"
            }
        }

        Mock New-NetFirewallRule { }
        Enable-SSHD -SSHZipFile $FAKE_ZIP
        Assert-MockCalled New-NetFirewallRule -Times 1  -Scope It
    }

    It "doesn't set up firewall when ssh is already set up " {
        Mock Get-NetFirewallRule {
            return [ordered]@{
                "Name" = "{ E02857AB-8EA8-4358-8119-ED7D20DA7712 }"
                "DisplayName" = "SSH"
                "Description" = ""
                "DisplayGroup" = ""
                "Group" = ""
                "Enabled" = "True"
                "Profile" = "Any"
                "Platform" = "{ }"
                "Direction" = "Inbound"
                "Action" = "Allow"
                "EdgeTraversalPolicy" = "Block"
                "LooseSourceMapping" = "False"
                "LocalOnlyMapping" = "False"
                "Owner" = ""
                "PrimaryStatus" = "OK"
                "Status" = "The rule was parsed successfully from the store. (65536)"
                "EnforcementStatus" = "NotApplicable"
                "PolicyStoreSource" = "PersistentStore"
                "PolicyStoreSourceType" = "Local"
            }
        }

        Mock New-NetFirewallRule { }
        Enable-SSHD -SSHZipFile $FAKE_ZIP
        Assert-MockCalled New-NetFirewallRule -Times 0 -Scope It
    }

    It "Generates inf and invokes LGPO if LGPO exists" {
        Mock Run-LGPO -Verifiable -ParameterFilter { $LGPOPath -eq "$TMP_DIR\Windows\LGPO.exe" -and $InfFilePath -eq "$TMP_DIR\Windows\Temp\enable-ssh.inf" }

        Enable-SSHD -SSHZipFile $FAKE_ZIP

        Assert-VerifiableMock
    }

    It "Skips LGPO if LGPO.exe not found" {
        rm "$TMP_DIR\Windows\LGPO.exe"

        Enable-SSHD -SSHZipFile $FAKE_ZIP

        Assert-MockCalled Run-LGPO -Times 0 -Scope It
    }

    Context "When LGPO executable fails" {
        It "Throws an appropriate error" {
            Mock Run-LGPO { throw "some error" } -Verifiable -ParameterFilter { $LGPOPath -eq "$TMP_DIR\Windows\LGPO.exe" -and $InfFilePath -eq "$TMP_DIR\Windows\Temp\enable-ssh.inf" }
            { Enable-SSHD -SSHZipFile $FAKE_ZIP } | Should -Throw "LGPO.exe failed with: some error"
        }
    }

    It "removes existing SSH keys" {
        New-Item -ItemType Directory -Path "$TMP_DIR\ProgramData\ssh" -ErrorAction Ignore
        echo "delete" > "$TMP_DIR\ProgramData\ssh\ssh_host_1"
        echo "delete" > "$TMP_DIR\ProgramData\ssh\ssh_host_2"
        echo "delete" > "$TMP_DIR\ProgramData\ssh\ssh_host_3"
        echo "ignore" > "$TMP_DIR\ProgramData\ssh\not_ssh_host_4"

        Enable-SSHD -SSHZipFile $FAKE_ZIP

        $numHosts = (Get-ChildItem "$TMP_DIR\ProgramData\ssh\").count
        $numHosts | Should -eq 1
    }

    It "creates empty ssh program dir if it doesn't exist" {
        Enable-SSHD -SSHZipFile $FAKE_ZIP
        { Test-Path "$TMP_DIR\ProgramData\ssh" } | Should -eq $True
    }
}
