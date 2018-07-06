# BOSH Windows Stemcell Automation [![slack.cloudfoundry.org](https://slack.cloudfoundry.org/badge.svg)](https://slack.cloudfoundry.org)

BOSH Windows stemcell automation is an automation tool used to create local BOSH Windows stemcells which can be deployed on [Cloud Foundry BOSH](https://bosh.io).

##Supported IaaS
The BOSH Windows stemcell automation tool will create stemcells for the following IaaS:
* VMware vSphere

##Supported Windows Server versions
The BOSH Windows stemcell automation tool is compatible with the following Windows versions:
* Windows Server 1709

##Prerequisites
The following need to be downloaded:
* Local Group Policy Object Utility v2.2 - [LGPO.exe](https://www.microsoft.com/en-us/download/details.aspx?id=55319)
* The appropriate BOSH Windows stemcell automation release for the desired Windows stemcell version - [StemcellAutomation.zip](https://github.com/cloudfoundry-incubator/bosh-windows-stemcell-automation/releases)
* A Windows Server 1709 installation disk ISO

##Creating a BOSH Windows stemcell
###1. Preparing the VM
The following steps are used to prepare the base VM image that will be used to create the final stemcell.

1. Refer to [Creating a vSphere Windows Stemcell](https://github.com/cloudfoundry-incubator/bosh-windows-stemcell-builder/wiki/Creating-a-vSphere-Windows-Stemcell)
    1. Review the **Quick Overview** section
1. Follow steps 1 through 3 of the guide

###2. Running the BOSH Windows stemcell automation tool
The following steps installs the binaries, as well as modify Windows settings and registries, to make it work in a BOSH environment.
1. Copy the `LGPO.exe` and `StemcellAutomation.zip` onto the VM created in the previous step.
1. Start Powershell
1. Extract the content of the `StemcellAutomation.zip` by executing the following command: `Expand-Archive .\StemcellAutomation.zip .`
1. Begin the automation process by executing the following command: `.\Setup.ps1`
    * During this step, the VM will reboot once and the second half of the automation will continue. At this stage, there is no visual feedback for the process; eventually, the VM will shutdown.
    * (Optional) To keep an eye on the progress after the reboot, follow these steps:
        * Log into the VM
        * Start Powershell
        * Execute the following command: `Get-Content -Path "C:\provision\log.log" -Wait`
1. Wait for the VM to shutdown

###3. Finalizing the stemcell creation process
This steps converts the VM image into a stemcell package.

1. Follow steps 6 and onward from [Creating a vSphere Windows Stemcell](https://github.com/cloudfoundry-incubator/bosh-windows-stemcell-builder/wiki/Creating-a-vSphere-Windows-Stemcell) guide.
