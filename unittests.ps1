#create a new VNET
$ResourceGroupName = "test-rg"

#creating VNET-1 in East US
$Location1 = "eastus"

Connect-AzAccount -TenantId "25dd58c6-88cf-4ebe-8870-f7c393c72c9b"
Get-AzContext

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId


New-AzResourceGroup -Name $ResourceGroupName -Location $Location1

$subnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name "MySubnet" `
    -AddressPrefix "10.0.1.0/24"

# 2. Create the VNET and include that Subnet
New-AzVirtualNetwork `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location1 `
    -Name "MyVNet" `
    -AddressPrefix "10.0.0.0/16" `
    -Subnet $subnetConfig


    #The follwing code will be used later.
    for($i=1; $i -le 3; $i++){
        #create web server NIC without public IP
        $nic = New-AZNicWithoutPublicIP -NicName ("webserver-nic0" + $i) `
        -VNetName $VNetName -SubnetName $SubnetName `
        -ResourceGroupName $ResourceGroupName -Location $Location `
        -ErrorAction Stop

        #VM parameters adjustments for web servers. First we remove some.
        #These are removed so that the newly created VM uses the NIC we created without public IP.
        $vmParameters.Remove("VirtualNetworkName") 
        $vmParameters.Remove("SubnetName") 
        $vmParameters.Remove("PublicIpAddress")

        #Then we set the name and open ports
        $webVmName = "webserver-vm0$i"
        $vmParameters["Name"] = $webVmName
        $vmParameters["OpenPorts"] = 80,443

        
        #create the web server vm
        New-AzVM @vmParameters -NetworkInterface $nic 

        Write-Host "Created web server VM: $webVmName" -ForegroundColor Green
        break; #to prevent multiple vm creation during testing
    }
     


        $WebServerVmParameters = @{
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        Name              = $Vmname
        Image             = $Image
        Size              = "Standard_B1s"
        Credential        = $Credential
        ErrorAction      = "Stop"
    }













    else {

    Write-Host "Public IP not needed. We will create 3 web servers here in a loop. These will NOT have public IPs." -ForegroundColor Yellow


    for($i=1; $i -le 3; $i++){
        #create web server NIC without public IP
        $nic = New-AZNicWithoutPublicIP -NicName ("webserver-nic0" + $i) `
        -VNetName $VNetName -SubnetName $SubnetName `
        -ResourceGroupName $ResourceGroupName -Location $Location `
        -ErrorAction Stop

       #Then we set the name and open ports
        $webVmName = "webserver-vm0$i"
        # 2. Build the Config Object
        # New-AzVMConfig ONLY takes Name and Size
        $webVMConfigObj = New-AzVMConfig -VMName $webVmName -VMSize "Standard_B1s"

        
        # 3. Add the NIC to the Config
        $webVMConfigObj = Add-AzVMNetworkInterface -VM $webVMConfigObj -Id $nic.Id

        $publisher, $offer, $sku, $version = $Image.Split(":") 
        $webVMConfigObj = Set-AzVMSourceImage -VM $webVMConfigObj `
        -PublisherName $publisher `
        -Offer $offer `
        -Skus $sku `
        -Version $versionvdv 

        # Linux OS config 
        $webVMConfigObj = Set-AzVMOperatingSystem -VM $webVMConfigObj -Linux `
        -ComputerName $webVmName `
        -Credential $Credential `
        -DisablePasswordAuthentication $false

        

        #create the web server vm
        New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $webVMConfigObj
        
        Write-Host "Created web server VM: $webVmName" -ForegroundColor Green
        break; #to prevent multiple vm creation during testing
    }
    
}


$extensionSettings = @{
        commandToExecute = "sudo apt-get update && sudo apt-get install -y xfce4 xfce4-goodies xrdp && echo xfce4-session > ~/.xsession && sudo systemctl restart xrdp"
        }

        Set-AzVMExtension -ResourceGroupName $ResourceGroupName `
            -Location $Location `
            -VMName $Vmname `
            -Name "InstallGUI" `
            -Publisher "Microsoft.Azure.Extensions" `
            -ExtensionType "CustomScript" `
            -TypeHandlerVersion "2.1" `
            -Settings $extensionSettings
        