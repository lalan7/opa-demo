#!/bin/bash

. ../../third_party/demo-magic/demo-magic.sh

clear

oc apply -f sync.yaml >> /dev/null
oc apply -f dryrun/existing_resources >> /dev/null

clear

echo "===== ENTER developer ====="
echo

pe "oc create ns advanced-transaction-system"
echo

echo "===== EXIT developer ====="
echo

NO_WAIT=true
p "Five weeks go by. Developer moves on to another project. \"advanced-transaction-system\" is long forgotten until..."
read
p "Our intrepid admin finds it. \"What is advanced-transaction-system? Do we use it?\""
read
p "They go on a three day quest across many departments..."
read
p "Only to find the project was scrapped."
read
p "\"Never again,\" says the admin as they delete the namespace."
NO_WAIT=false

clear
echo
echo "===== ENTER admin ====="
echo

pe "ls -1 templates"
echo

pe "oc apply -f templates"
echo

pe "ls -1 constraints"
echo

pe "cat constraints/owner_must_be_provided.yaml"
echo

pe "oc apply -f constraints"
echo

echo "===== ENTER developer ======"
echo

pe "oc create ns production"
echo

pe "cat good_resources/namespace.yaml"
echo

pe "oc apply -f good_resources/namespace.yaml"
echo

pe "oc apply -f bad_resources/opa_no_limits.yaml"
echo

pe "oc apply -f bad_resources/opa_limits_too_high.yaml"
echo

pe "oc apply -f bad_resources/opa_wrong_repo.yaml"
echo

pe "oc apply -f good_resources/opa.yaml"
echo

pe "cat bad_resources/duplicate_service.yaml"
echo

pe "oc apply -f bad_resources/duplicate_service.yaml"
echo

p "After some more trial and error, the developer's service is up and running"

echo
echo "===== EXIT developer ====="
echo

clear
NO_WAIT=true
p "All is well with the world, until the big outage. The bank is down for hours."
read

echo "===== ENTER admin ====="
echo
p "We had no idea there were resources in the cluster without resource limits. Now they are causing issues in production!"
echo
p "We need to get all the resources in the cluster that lack resource limits."
read
p "Let's check out the audit results of the container-must-have-limits constraint!"
read

NO_WAIT=false
pe "oc get k8scontainerlimits.constraints.gatekeeper.sh  container-must-have-limits -o yaml"
echo
wait
clear

p "Weeks gone by, the company now has a new policy to rollout to production."
echo

p "We need to ensure all ingress hostnames are unique."
echo

p "Introducing new policies is dangerous and can often be a breaking change. How do we gain confidence in the new policy before enforcing them in production? What if it breaks a core piece of software, what if it brings down the entire stack?!"
echo

echo "===== ENTER admin ====="
echo
p "We can use the dry run feature in Gatekeeper to preview the effect of policy changes in production without impacting the workload and our users!"
read

clear
NO_WAIT=false

pe "oc apply -f dryrun/k8suniqueingresshost_template.yaml"
echo

pe "oc apply -f dryrun/unique-ingress-host.yaml"
echo

pe "cat dryrun/k8suniqueingresshost_template.yaml"
echo

pe "cat dryrun/unique-ingress-host.yaml"
echo

pe "oc get ingress --all-namespaces"
echo

pe "oc get K8sUniqueIngressHost.constraints.gatekeeper.sh  unique-ingress-host -o yaml"
echo

p "Let's see if this new policy in dry run mode blocks operations on the cluster?"
echo

pe "cat dryrun/bad_resource/duplicate_ing.yaml"
echo

pe "oc apply -f dryrun/bad_resource/duplicate_ing.yaml"
echo


p "THE END"

oc delete -f dryrun/existing_resources
oc delete -f dryrun/bad_resource/
oc delete -f dryrun
oc delete -f good_resources
oc delete ns advanced-transaction-system
oc delete -f constraints
oc delete -f templates
oc delete -f sync.yaml
