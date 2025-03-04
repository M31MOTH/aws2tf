#!/bin/bash
if [ "$1" != "" ]; then
    cmd[0]="$AWS ec2 describe-transit-gateway-vpc-attachments --filters \"Name=transit-gateway-id,Values=$1\" \"Name=state,Values=available\""
else
    cmd[0]="$AWS ec2 describe-transit-gateway-vpc-attachments --filters \"Name=state,Values=available\""
fi

pref[0]="TransitGatewayVpcAttachments"
tft[0]="aws_ec2_transit_gateway_vpc_attachment"
tgwlist=()
for c in `seq 0 0`; do
    cm=${cmd[$c]}
	ttft=${tft[(${c})]}
	#echo $cm
    awsout=`eval $cm 2> /dev/null`
    if [ "$awsout" == "" ];then
        echo "$cm : You don't have access for this resource"
        exit
    fi
    count=`echo $awsout | jq ".${pref[(${c})]} | length"`


    if [ "$count" -gt "0" ]; then
        count=`expr $count - 1`
        # pre-get resources
        for i in `seq 0 $count`; do
        # vpcid
        attvpcid=`echo $awsout | jq ".${pref[(${c})]}[(${i})].VpcId" | tr -d '"'`
        #echo $attvpcid
        #attsubs=`echo $awsout | jq ".${pref[(${c})]}[(${i})].SubnetIds"`
        #echo $awsout | jq ".${pref[(${c})]}[(${i})].SubnetIds"
        #echo "attsubs"
        #echo $attsubs | jq .
        #exit
        ../../scripts/100-get-vpc.sh $attvpcid
        ../../scripts/105-get-subnet.sh $attvpcid
        # subnets in above vpc
        
        # tgws
        tgwid=`echo $awsout | jq ".${pref[(${c})]}[(${i})].TransitGatewayId" | tr -d '"'`

        done
        
        for i in `seq 0 $count`; do
            #echo $i
            cname=`echo $awsout | jq ".${pref[(${c})]}[(${i})].TransitGatewayAttachmentId" | tr -d '"'`
            tgwid=`echo $awsout | jq ".${pref[(${c})]}[(${i})].TransitGatewayId" | tr -d '"'`
            echo "$ttft $cname" $tgwid
            fn=`printf "%s__%s.tf" $ttft $cname`
            if [ -f "$fn" ] ; then echo "$fn exists already skipping" && continue; fi
            printf "resource \"%s\" \"%s\" {}" $ttft $cname > $fn

            terraform import $ttft.$cname "$cname" | grep Import
            terraform state show $ttft.$cname | perl -pe 's/\x1b.*?[mGKH]//g' > t1.txt
            rm -f $fn

            file="t1.txt"

            echo $aws2tfmess > $fn
            while IFS= read line
            do
				skip=0
                # display $line or do something with $line
                t1=`echo "$line"` 
                if [[ ${t1} == *"="* ]];then
                    tt1=`echo "$line" | cut -f1 -d'=' | tr -d ' '` 
                    tt2=`echo "$line" | cut -f2- -d'='`
                    if [[ ${tt1} == "arn" ]];then skip=1; fi                
                    if [[ ${tt1} == "id" ]];then skip=1; fi          
                    if [[ ${tt1} == "role_arn" ]];then skip=1;fi
                    if [[ ${tt1} == "association_default_route_table_id" ]];then skip=1;fi
                    if [[ ${tt1} == "vpc_owner_id" ]];then skip=1;fi
                    if [[ ${tt1} == "owner_id" ]];then skip=1;fi
                    #if [[ ${tt1} == "default_route_table_id" ]];then skip=1;fi
                    #if [[ ${tt1} == "owner_id" ]];then skip=1;fi
                    #if [[ ${tt1} == "default_network_acl_id" ]];then skip=1;fi
                    #if [[ ${tt1} == "ipv6_association_id" ]];then skip=1;fi
                    #if [[ ${tt1} == "ipv6_cidr_block" ]];then skip=1;fi
                    if [[ ${tt1} == "vpc_id" ]]; then
                        vpcid=`echo $tt2 | tr -d '"'`
                        t1=`printf "%s = aws_vpc.%s.id" $tt1 $vpcid`
                    fi
                    if [[ ${tt1} == "transit_gateway_id" ]]; then
                        tt2=`echo $tt2 | tr -d '"'`
                        t1=`printf "%s = aws_ec2_transit_gateway.%s.id" $tt1 $tt2`
                    fi
                else
                    if [[ "$t1" == *"subnet-"* ]]; then
                        t1=`echo $t1 | tr -d '"|,'`
                        t1=`printf "aws_subnet.%s.id," $t1`
                    fi

                fi
                if [ "$skip" == "0" ]; then
                    #echo $skip $t1
                    echo "$t1" >> $fn
                fi
                
            done <"$file"
            tgwlist+=( "${tgwid}" )
            if [[ $vpcid != "" ]];then
                ../../scripts/100-get-vpc.sh $vpcid
            fi
            # get the TGW itself

        done

        ## defer to TGW

        for tgwi in ${tgwlist[@]}; do
            echo "tgw = $tgwi"
            ../../scripts/201-get-transit-gateway.sh $tgwi
            ../../scripts/202-get-transit-gateway-route-tables.sh $tgwi
        done

    fi
done

rm -f t*.txt

