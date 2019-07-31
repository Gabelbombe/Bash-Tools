#!/bin/bash -x

# Write the policy to dev and live
for ENV in owf-dev owf-live ; do
	echo Renew $ENV token.
	VAULT_TOKEN=`cat ~/.vault-token.${ENV}` vault token-renew --address=http://vault.service.${ENV}:8200
done
