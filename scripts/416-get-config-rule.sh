#!/bin/bash
if [ "$1" != "" ]; then
    cmd[0]="$AWS configservice describe-config-rules  --config-rule-names $1" 
else
    cmd[0]="$AWS configservice describe-config-rules"
fi

pref[0]="ConfigRules"
tft[0]="aws_config_config_rule"
idfilt[0]="ConfigRuleName"

#rm -f ${tft[0]}.tf

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
        for i in `seq 0 $count`; do
            #echo $i
            cname=`echo $awsout | jq ".${pref[(${c})]}[(${i})].${idfilt[(${c})]}" | tr -d '"'`
            echo "$ttft $cname"
            fn=`printf "%s__%s.tf" $ttft $cname`
            if [ -f "$fn" ] ; then
                echo "$fn exists already skipping"
                continue
            fi
            printf "resource \"%s\" \"%s\" {" $ttft $cname > $ttft.$cname.tf
            printf "}" >> $ttft.$cname.tf
            printf "terraform import %s.%s %s" $ttft $cname $cname > data/import_$ttft_$cname.sh
            terraform import $ttft.$cname "$cname" | grep Import
            terraform state show $ttft.$cname > t2.txt
            tfa=`printf "data/%s.%s" $ttft $cname`
            terraform show  -json | jq --arg myt "$tfa" '.values.root_module.resources[] | select(.address==$myt)' > $tfa.json
            #echo $awsj | jq . 
            rm $ttft.$cname.tf
            cat t2.txt | perl -pe 's/\x1b.*?[mGKH]//g' > t1.txt
            #	for k in `cat t1.txt`; do
            #		echo $k
            #	done
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
                    if [[ ${tt1} == "owner_id" ]];then skip=1;fi
                    if [[ ${tt1} == "rule_id" ]];then skip=1;fi
                    #if [[ ${tt1} == "availability_zone" ]];then skip=1;fi
                    if [[ ${tt1} == "availability_zone_id" ]];then skip=1;fi
                    if [[ ${tt1} == "vpc_id" ]]; then
                        tt2=`echo $tt2 | tr -d '"'`
                        t1=`printf "%s = aws_vpc.%s.id" $tt1 $tt2`
                    fi
                    if [[ ${tt1} == "description" ]]; then
                        tt2=`echo "$tt2" | tr -d '"'`
                        dl=${#tt2}
                        echo $dl $tt2
                        if [[ $dl -gt 254 ]];then 
                        tt2=${tt2:0:252}; 
                        echo "shortened"
                        fi
                        dl=${#tt2}
                        echo $dl $tt2
                        t1=`printf "%s = \"%s\"" $tt1 "$tt2"`
                        printf "lifecycle {\n" >> $fn
                        printf "   ignore_changes = [description]\n" >> $fn
                        printf "}\n" >> $fn
                    fi
                    if [[ ${tt1} == "name" ]]; then
                        tt2=`echo "$tt2" | tr -d '"'`
                        nl=${#tt2}
                        if [[ $nl -gt 64 ]];then tt2=${tt2:0:64}; fi
                        tt2=$(echo $tt2 | tr -d ' ')
                        t1=`printf "%s = \"%s\"" $tt1 "$tt2"`
                    fi
               
                fi
                if [ "$skip" == "0" ]; then
                    #echo $skip $t1
                    echo "$t1" >> $fn
                fi
                
            done <"$file"

            
        done

    fi
done

rm -f t*.txt

