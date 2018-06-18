. ./AutomationHelpers.ps1

Describe "CopyPSModules" {
    It "can copy PS Modules to target directory" {
        Mock Write-Log {}
        Mock Expand-Archive {}

        { CopyPSModules } | Should -Not -Throw

        Assert-MockCalled Expand-Archive -Times 1 -Scope It -ParameterFilter { $LiteralPath -eq ".\bosh-psmodules.zip" -and $DestinationPath -eq "C:\Program Files\WindowsPowerShell\Modules\" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Succesfully migrated Bosh Powershell modules to destination dir" }
    }

    It "fails gracefully when expanding archive fails" {
        Mock Expand-Archive { throw "Expand-Archive failed because something went wrong" }
        Mock Write-Log {}

        { CopyPSModules } | Should -Throw "Expand-Archive failed because something went wrong"

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Expand-Archive failed because something went wrong" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to copy Bosh Powershell Modules into destination dir. See 'c:\provisions\log.log' for mor info." }
    }
}

Describe "InstallCFFeatures" {
    It "executes the Install-CFFeatures powershell cmdlet" {
        Mock Install-CFFeatures {}
        Mock Write-Log {}

        { InstallCFFeatures } | Should -Not -Throw

        Assert-MockCalled Install-CFFeatures -Times 1 -Scope It
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Successfully installed CF features" }
    }

    It "fails gracefully when installing CF Features" {
        Mock Install-CFFeatures { throw "Something terrible happened while attempting to install a CF feature" }
        Mock Write-Log {}

        { InstallCFFeatures } | Should -Throw "Something terrible happened while attempting to install a CF feature"

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Something terrible happened while attempting to install a CF feature"}
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to install the CF features. See 'c:\provisions\log.log' for mor info."}
    }
}

Describe "InstallCFCell" {
    It "executes the Protect-CFCell powershell cmdlet" {
        Mock Protect-CFCell {}
        Mock Write-Log {}

        { InstallCFCell } | Should -Not -Throw

        Assert-MockCalled Protect-CFCell -Times 1
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Succesfully ran Protect-CFCell" }
    }

    It "fails gracefully when Protect-CFCell powershell cmdlet fails" {
        Mock Protect-CFCell { throw "Something terrible happened while attempting to execute Protect-CFCell" }
        Mock Write-Log {}

        { InstallCFCell } | Should -Throw "Something terrible happened while attempting to execute Protect-CFCell"

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Something terrible happened while attempting to execute Protect-CFCell"}
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to execute Protect-CFCell powershell cmdlet. See 'c:\provisions\log.log' for mor info."}
    }

}

Describe "InstallBoshAgent" {
    It "executes the Install-Agent powershell cmdlet" {
        Mock Install-Agent {}
        Mock Write-Log {}

        { InstallBoshAgent } | Should -Not -Throw


        Assert-MockCalled Install-Agent -Times 1 -Scope It -ParameterFilter { $IaaS -eq "vsphere" -and $agentZipPath -eq ".\agent.zip" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Bosh agent successfully installed" }
    }

    It "fails gracefully when Install-Agent powershell cmdlet fails" {
        Mock Install-Agent { throw "Something terrible happened while attempting to execute Install-Agent" }
        Mock Write-Log {}

        { InstallBoshAgent } | Should -Throw "Something terrible happened while attempting to execute Install-Agent"

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Something terrible happened while attempting to execute Install-Agent" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to execute Install-Agent powershell cmdlet. See 'c:\provisions\log.log' for mor info." }
    }
}

Describe "InstallOpenSSH" {
    It "executes the Install-SSHD powershell cmdlet" {
        Mock Install-SSHD {}
        Mock Write-Log {}

        { InstallOpenSSH } | Should -Not -Throw


        Assert-MockCalled Install-SSHD -Times 1 -Scope It -ParameterFilter { $SSHZipFile -eq ".\OpenSSH-Win64.zip" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "OpenSSH successfully installed" }
    }

    It "fails gracefully when Install-SSHD powershell cmdlet fails" {
        Mock Install-SSHD { throw "Something terrible happened while attempting to execute Install-SSHD" }
        Mock Write-Log {}

        { InstallOpenSSH } | Should -Throw "Something terrible happened while attempting to execute Install-SSHD"

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Something terrible happened while attempting to execute Install-SSHD" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to execute Install-SSHD powershell cmdlet. See 'c:\provisions\log.log' for mor info." }
    }
}

Describe "CleanUpVM" {
    It "executes the Optimize-Disk and Compress-Disk powershell cmdlet" {
        Mock Optimize-Disk {}
        Mock Compress-Disk {}
        Mock Write-Log {}

        { CleanUpVM } | Should -Not -Throw

        Assert-MockCalled Optimize-Disk -Times 1 -Scope It
        Assert-MockCalled Compress-Disk -Times 1 -Scope It
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Successfully cleaned up the VM's disk" }
    }

    It "fails gracefully when Optimize-Disk powershell cmdlet fails" {
        Mock Optimize-Disk { throw "Something terrible happened while attempting to execute Optimize-Disk" }
        Mock Compress-Disk {}
        Mock Write-Log {}

        { CleanUpVM } | Should -Throw "Something terrible happened while attempting to execute Optimize-Disk"

        Assert-MockCalled Optimize-Disk -Times 1 -Scope It
        Assert-MockCalled Compress-Disk -Times 0 -Scope It

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Something terrible happened while attempting to execute Optimize-Disk" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to clean up the VM's disk. See 'c:\provisions\log.log' for mor info." }
    }

    It "fails gracefully when Compress-Disk powershell cmdlet fails" {
        Mock Optimize-Disk {}
        Mock Compress-Disk { throw "Something terrible happened while attempting to execute Compress-Disk" }
        Mock Write-Log {}

        { CleanUpVM } | Should -Throw "Something terrible happened while attempting to execute Compress-Disk"

        Assert-MockCalled Optimize-Disk -Times 1 -Scope It
        Assert-MockCalled Compress-Disk -Times 1 -Scope It

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Something terrible happened while attempting to execute Compress-Disk" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to clean up the VM's disk. See 'c:\provisions\log.log' for mor info." }
    }
}

Describe "SysprepVM" {
    It "copies LGPO to the correct destination and executes the Invoke-Sysprep powershell cmdlet" {
        Mock Expand-Archive {}
        Mock Invoke-Sysprep {}
        Mock GenerateRandomPassword { "SomeRandomPassword" }
        Mock Write-Log {}

        { SysprepVM } | Should -Not -Throw

        Assert-MockCalled Expand-Archive -Times 1 -Scope It -ParameterFilter { $LiteralPath -eq ".\LGPO.zip" -and $DestinationPath -eq "C:\Windows\" }
        Assert-MockCalled GenerateRandomPassword -Times 1 -Scope It
        Assert-MockCalled Invoke-Sysprep -Times 1 -Scope It -ParameterFilter { $IaaS -eq "vsphere" -and $NewPassword -eq "SomeRandomPassword" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Successfully migrated LGPO to destination dir" }
    }

    It "fails gracefully when Expand-Archive powershell cmdlet fails" {
        Mock Expand-Archive { throw "Expand-Archive failed because something went wrong" }
        Mock Invoke-Sysprep {}
        Mock GenerateRandomPassword { "SomeRandomPassword" }
        Mock Write-Log {}

        { SysprepVM } | Should -Throw "Expand-Archive failed because something went wrong"

        Assert-MockCalled Expand-Archive -Times 1 -Scope It -ParameterFilter { $LiteralPath -eq ".\LGPO.zip" -and $DestinationPath -eq "C:\Windows\" }
        Assert-MockCalled GenerateRandomPassword -Times 0 -Scope It
        Assert-MockCalled Invoke-Sysprep -Times 0 -Scope It -ParameterFilter { $IaaS -eq "vsphere" -and $NewPassword -eq "SomeRandomPassword" }

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Expand-Archive failed because something went wrong" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to Sysprep the VM's. See 'c:\provisions\log.log' for mor info." }
    }

    It "fails gracefully when Invoke-Sysprep powershell cmdlet fails" {
        Mock Expand-Archive {}
        Mock Invoke-Sysprep { throw "Invoke-Sysprep failed because something went wrong" }
        Mock GenerateRandomPassword { "SomeRandomPassword" }
        Mock Write-Log {}

        { SysprepVM } | Should -Throw "Invoke-Sysprep failed because something went wrong"

        Assert-MockCalled Expand-Archive -Times 1 -Scope It -ParameterFilter { $LiteralPath -eq ".\LGPO.zip" -and $DestinationPath -eq "C:\Windows\" }
        Assert-MockCalled GenerateRandomPassword -Times 1 -Scope It
        Assert-MockCalled Invoke-Sysprep -Times 1 -Scope It -ParameterFilter { $IaaS -eq "vsphere" -and $NewPassword -eq "SomeRandomPassword" }

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Invoke-Sysprep failed because something went wrong" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to Sysprep the VM's. See 'c:\provisions\log.log' for mor info." }
    }

    It "fails gracefully when GenerateRandomPassword function fails" {
        Mock Expand-Archive {}
        Mock Invoke-Sysprep {}
        Mock GenerateRandomPassword { throw "GenerateRandomPassword failed because something went wrong" }
        Mock Write-Log {}

        { SysprepVM } | Should -Throw "GenerateRandomPassword failed because something went wrong"

        Assert-MockCalled Expand-Archive -Times 1 -Scope It -ParameterFilter { $LiteralPath -eq ".\LGPO.zip" -and $DestinationPath -eq "C:\Windows\" }
        Assert-MockCalled GenerateRandomPassword -Times 1 -Scope It
        Assert-MockCalled Invoke-Sysprep -Times 0 -Scope It

        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "GenerateRandomPassword failed because something went wrong" }
        Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to Sysprep the VM's. See 'c:\provisions\log.log' for mor info." }
    }
}

Describe "GenerateRandomPassword" {

    It "generates a valid password" {
        Mock Get-Random { "changeMe123!".ToCharArray() }
        Mock Valid-Password { $True }
        Mock Write-Log{}
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
        Mock Write-Log{}

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
        }}
}

Describe "Is-Special" {
    It "returns true when given a valid special character" {
        $CharList = "!`"#$%&'()*+,-./:;<=>?@[\]^_``{|}~".ToCharArray()
        foreach ($c in $CharList) {
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

function GenerateDepJson {
    param(  [parameter(Mandatory=$true)] [string]$file1Sha,
            [parameter(Mandatory=$true)] [string]$file2Sha,
            [parameter(Mandatory=$true)] [string]$file3Sha
    )

    return "{""file1.zip"":{""sha"":""$file1Sha"",""version"":""1.0""},""file2.zip"":{""sha"":""$file2Sha"",""version"":""1.0-alpha""},""file3.exe"":{""sha"":""$file3Sha"",""version"":""3.0""}}"
}

Describe "Check-Dependencies" {
    BeforeEach {
        Mock Write-Log {}

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

        Mock Get-FileHash {New-Object PSObject -Property $file1Hash} -ParameterFilter { $Path -cmatch "$PSScriptRoot/file1.zip" }
        Mock Get-FileHash {New-Object PSObject -Property $file2Hash} -ParameterFilter { $Path -cmatch "$PSScriptRoot/file2.zip" }
        Mock Get-FileHash {New-Object PSObject -Property $file3Hash} -ParameterFilter { $Path -cmatch "$PSScriptRoot/file3.exe" }

        Mock Test-Path { $true } -ParameterFilter { $Path -cmatch "$PSScriptRoot/file1.zip" }
        Mock Test-Path { $true } -ParameterFilter { $Path -cmatch "$PSScriptRoot/file2.zip" }
        Mock Test-Path { $true } -ParameterFilter { $Path -cmatch "$PSScriptRoot/file3.exe" }

        #We specify when to throw the exception to prevent other test from being polluted when calling Convert-FromJson
        Mock ConvertFrom-Json {throw "Invalid JSON primitive: bad-json-format"} -ParameterFilter { $InputObject -match "bad-json-format" }
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
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate required dependencies. See 'c:\provisions\log.log' for more info." }

        }

        It "is empty" {
            Mock Get-Content { "" }

            { Check-Dependencies } | Should -Throw "Dependency file is empty"

            Assert-MockCalled Get-Content -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/deps.json" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Dependency file is empty" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate required dependencies. See 'c:\provisions\log.log' for more info." }
        }

        It "contains an empty json object" {
            Mock Get-Content { "{}" }

            { Check-Dependencies } | Should -Throw "Dependency file is empty"

            Assert-MockCalled Get-Content -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/deps.json" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Dependency file is empty" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate required dependencies. See 'c:\provisions\log.log' for more info." }
        }

        It "content is badly formatted" {
            Mock Get-Content {"bad-json-format"}

            { Check-Dependencies } | Should -Throw "Invalid JSON primitive: bad-json-format"

            Assert-MockCalled Get-Content -Times 1 -Scope It -ParameterFilter { $Path -cmatch "$PSScriptRoot/deps.json" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Invalid JSON primitive: bad-json-format" }
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate required dependencies. See 'c:\provisions\log.log' for more info." }

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
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate required dependencies. See 'c:\provisions\log.log' for more info." }
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
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate required dependencies. See 'c:\provisions\log.log' for more info." }
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
            Assert-MockCalled Write-Log -Times 1 -Scope It -ParameterFilter { $Message -eq "Failed to validate required dependencies. See 'c:\provisions\log.log' for more info." }
        }
    }
}