#### Configuration Variables
## Accepting Account/VPC Information
$AcceptingAcctID = '012345543210'       ## AWS Account ID of accepting connection request
$AcceptingAcctProfie = ''               ## IAM profile configured on local machine with permission to run command
$AcceptingAcctRegion = 'us-west-2'      ## Region Where VPC is depolyed
$AcceptingAcctVpcId = ''                ## ID of VPC to accept connection
$AcceptingAcctRouteTableID = ''         ## ID of Route Table needed to be updated

## Requesting Account/VPC Information
$RequestingAcctProfile = ''             ## IAM profile configured on local machine with permission to run command
$RequestingAcctRegion = 'us-west-2'     ## Region Where VPC is depolyed
$RequestingAcctVpcId = ''               ## ID of VPC to requesting peering connection
$RequestingAcctRouteTableID = ''        ## ID of Route Table needed to be updated

## Do All Peering Operations
function New-PeeringConnection {

    ## Collect Peering VPC Information
    $acceptingVpcInfo = Get-Ec2Vpc -VpcId $AcceptingAcctVpcId  -Region $AcceptingAcctRegion -ProfileName $AcceptingAcctProfile
    $requestingVpcInfo = Get-Ec2Vpc -VpcId $RequestingAcctVpcId -Region $AcceptingAcctRegion -ProfileName $RequestingAcctProfile

    ## Create Connection Request
    $connectionRequestInfo = New-EC2VpcPeeringConnection -VpcId $requestingVpcInfo.VpcId -PeerOwnerId $AcceptingAcctID -PeerVpcId $AcceptingAcctVpcId -ProfileName $RequestingAcctProfile -Region $RequestingAcctRegion

    ## Approve Request
    $approvedrequest = Approve-EC2VpcPeeringConnection -VpcPeeringConnectionId $connectionRequestInfo.VpcPeeringConnectionId -ProfileName $AcceptingAcctProfie -Region $AcceptingAcctRegion

    ## Get route table information for assigning routes
    $acceptingVpcRouteTable = Get-EC2RouteTable -RouteTableId $AcceptingAcctRouteTable -ProfileName $AcceptingAcctProfile -Region $AcceptingAcctRegion
    $requestingVpcRouteTable = Get-EC2RouteTable -RouteTableId $RequestingAcctRouteTableID -ProfileName $RequestingAcctProfile -Region $RequestingAcctRegion

    ## Configure routes in respective routetables
    New-Ec2Route -DestinationCidrBlock $requestingVpcInfo.CidrBlock -RouteTableId $acceptingVpcRouteTable.RouteTableId -GatewayId $connectionRequestInfo.VpcPeeringConnectionId -ProfileName $AcceptingAcctProfie -Region $RequestingAcctRegion
    New-Ec2Route -DestinationCidrBlock $acceptingVpcInfo.CidrBlock -RouteTableId $requestingVpcRouteTable.RouteTableId -GatewayId $connectionRequestInfo.VpcPeeringConnectionId -ProfileName $RequestingAcctProfie  -Region $RequestingAcctRegion

}

New-PeeringConnection