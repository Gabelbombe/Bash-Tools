#!/usr/local/bin/bash

##############################################################################################################################################
# This script should help anyone who wants to add multiple instances to a codedeploy deployment group.                                       #
# It relies heavily on tags. So if the tags are off, this script won't pick up the instance correctly.                                       #
# It assumes you have aws cli and jq - commandline JSON processor installed on your local and you have                                       #
# multiple aws profiles. This script is particularly targeted for DLE apps which follow DLE-<SUBCOMPONENT>-<ENV> convention                  #
# You can pass the profile name that's in ~/.aws/credentials file as the third argument to the script                                        #
##############################################################################################################################################

function usage()
{
    echo "Usage: `basename $0` <appname> <subcomponent name> <environment> <delployment name>" ; exit 1
}

function toUpper()
{
    echo "${1}" |tr '[:lower:]' '[:upper:]'
}

function toLower()
{
    echo "${1}" |tr '[:upper:]' '[:lower:]'
}

#set -x
[ "$#" -eq 4 ] || usage

region="us-east-1"
awsacct="$(aws ec2 describe-security-groups --group-name 'Default' --query 'SecurityGroups[0].OwnerId' --output text)"
profile='nonprod'   # profile="$(toLower $4)"

app="$(toLower $1)"
subcomp="$(toLower $2)"
envname="$(toLower $3)"

deployname="$(toLower $4)"
if [[ ! "$deployname" ]] ; then
  deployname="${subcomp}"
fi


echo
echo "Using Application: $app"
echo "Using AWS Profile: $profile"
echo "Using Account Num: $awsacct"
echo

#Get all hosts based on tags for this aws environment
hostgroup=$(aws ec2 describe-instances --filter Name=tag:Name,Values=\*${subcomp}\* Name=tag:Environment,Values=${envname} --profile=$profile --region=$region |jq '.Reservations[].Instances[].Tags[] | select(.Key == "Name") | .Value' |sed  's/"//g' |sort)

for host in $hostgroup ; do
	echo "Found Host:        $host"

	#For some consistency in naming conventions
	env=$(toUpper $envname)        # `echo $envname|tr '[:lower:]' '[:upper:]'`
	app_name=$(toUpper $app)       # `echo $app|tr '[:lower:]' '[:upper:]'`
	sub_comp=$(toUpper $deployname)   # `echo $subcomp|tr '[:lower:]' '[:upper:]'`

	#concatenate the tags string so you dont override the existing values, you want to update not override
	tags="$tags Key=Name,Value=$host,Type=KEY_AND_VALUE"

	#Make sure you are not being crazy
	echo $tags

	# Does this deployment group already exist? If it does, update it, else create it
	aws deploy get-deployment-group --application-name $app_name --deployment-group-name $app_name-$sub_comp-$env --profile=$profile --region=$region

	if [ $? -eq 0 ] ; then
		echo -e "\n[UPDATING] -> $app_name-$env"
		aws deploy update-deployment-group --application-name $app_name  --deployment-config-name CodeDeployDefault.OneAtATime --current-deployment-group-name $app_name-$sub_comp-$env --ec2-tag-filters  $tags  --service-role-arn arn:aws:iam::$awsacct:role/AWSCodeDeploy --profile=$profile --region=$region
	else
		echo -e "\n[CREATING] -> $app_name-$sub_comp-$env"
		aws deploy create-deployment-group --application-name $app_name  --deployment-config-name CodeDeployDefault.OneAtATime --deployment-group-name $app_name-$sub_comp-$env --ec2-tag-filters  $tags  --service-role-arn arn:aws:iam::$awsacct:role/AWSCodeDeploy --profile=$profile --region=$region
	fi
done
