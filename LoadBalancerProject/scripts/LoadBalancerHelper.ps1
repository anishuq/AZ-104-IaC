Write-Host "Creating Load Balancer now..." -ForegroundColor Green

function New-AzWebLoadBalancer {
    param (
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$LoadBalancerName,
        [string]$VnetName,
        [string]$SubnetName
    )
    
    $LbFrontendPIP = New-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Location $Location `
        -Name "$LoadBalancerName-frontend-pip" -AllocationMethod Static -Sku Standard

    $FrontendIPConfig = New-AzLoadBalancerFrontendIpConfig -Name "$LoadBalancerName-frontend-ipconfig" `
        -PublicIpAddress $LbFrontendPIP

    $BackendVMPool = New-AzLoadBalancerBackendAddressPoolConfig -Name "$LoadBalancerName-backend-pool"

    $HealthProbeConfig = New-AzLoadBalancerProbeConfig -Name "$LoadBalancerName-HTTP-Health-probe" `
        -Protocol Tcp -Port 80 -IntervalInSeconds 15 -ProbeCount 2

    # 5. Load balancing rule — frontend port 80 to backend port 80, no session persistence    
    $RuleConfigParams = @{
        Name                     = "$LoadBalancerName-HTTP-rule"
        FrontendIpConfiguration  = $FrontendIPConfig
        BackendAddressPool       = $BackendVMPool
        Probe                    = $HealthProbeConfig
        Protocol                 = "Tcp"
        FrontendPort             = 80
        BackendPort              = 80
        LoadDistribution         = "Default"
        #5-tuple hashing algorithm is used to distribute traffic across the backend pool
    }
    
    $LoadBalancingRuleConfig = New-AzLoadBalancerRuleConfig @RuleConfigParams -ErrorAction Stop          
    
    $LoadBalancerParameters = @{
        Name              = $LoadBalancerName   
        ResourceGroupName = $ResourceGroupName
        Location          = $Location           
        Sku               = "Standard"
        FrontendIpConfiguration = $FrontendIPConfig
        BackendAddressPool = $BackendVMPool
        Probe = $HealthProbeConfig              
        LoadBalancingRule = $LoadBalancingRuleConfig    
    }
    
    $LoadBalancerObj = New-AzLoadBalancer @LoadBalancerParameters -ErrorAction Stop
    Write-Host "Load Balancer created successfully!" -ForegroundColor Green

    return $LoadBalancerObj
}