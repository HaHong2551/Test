SHELL:=/bin/bash
###################
# For Terraform
###################
#Set ENV & SERVICE
.PHONY: set_env
set_env:
ifndef e
$(error Error: ENV is undefined, please add to your command `e=dev or e=stg or e=prd or e=...`)
endif

.PHONY: check_env
check_env: set_env
ifeq ($(filter %$(e)/,$(shell ls -d envs/*/)),)
$(error Error: ENV defined is "$(e)" but not exists)
else
$(info ENV: "$(e)")
endif

.PHONY: set_service
set_service:
ifndef s
s := SERVICE
endif

.PHONY: check_service
check_service: check_env set_service
		@if [ "$s" = "SERVICE" ]; then \
			echo 'Error: SERVICE is required but no definition was found, still default value: "$(s)"' && \
			exit 1; \
		else \
			for service in $$(ls -d envs/$(e)/*/ | cut -d . -f2 | cut -d / -f1); do \
				if [ "$s" = $$service ]; then \
					echo 'SERVICE: "$(s)"'; \
				elif echo $$(ls -d envs/$(e)/*/ | cut -d . -f2 | cut -d / -f1) | grep -qFw "$s"; then \
					continue; \
				else \
					echo 'Error: SERVICE defined is "$(s)" but not exists' && \
					exit 1; \
				fi \
			done \
		fi \
	
.PHONY: set_target
set_target:
ifndef t
t := module.TARGET
endif

.PHONY: check_target
check_target: check_env check_service set_target
		@if [ "$t" = "module.TARGET" ]; then \
			echo 'Error: TARGET is required but no definition was found, still default value: "$(t)"' && \
			exit 1; \
		else \
			echo 'TARGET: "$(t)"'; \
		fi \

.PHONY: set_other_target
set_other_target:
ifndef ot
ot := OTHER_TARGET
endif

.PHONY: check_other_target
check_other_target: check_env check_service check_target set_other_target
		@if [ "$(ot)" = "OTHER_TARGET" ]; then \
			echo 'Error: OTHER TARGET is required but no definition was found, still default value: "$(ot)"' && \
			exit 1; \
		else \
			echo 'OTHER TARGET: "$(ot)"'; \
		fi \


#Symlink: When creating new service
.PHONY: symlink
symlink: check_env check_service
	@service_path=$$(ls -dl envs/$(e)/* | grep '^d' | grep $(s) | head -n 1 | grep -o '[^ ]*$$') && VAR="_variables.tf" && \
	ln -sfn $(shell pwd)/envs/$(e)/_variables.tf $(shell pwd)/$$service_path && \
	if grep -w ".gitignore" -e "$$service_path/$$VAR"; then \
		echo "Do not need to add this symlink to .gitignore"; \
	else \
		find $$service_path -type l >> .gitignore && \
		echo Add \"$$service_path/_variables.tf\" symlink to .gitignore; \
	fi \

.PHONY: symlink_all
symlink_all: check_env
	@service_path=$$(ls -dl envs/$(e)/* | grep '^d' | grep -o '[^ ]*$$') && VAR="_variables.tf" && \
	for service in $$service_path; do \
		ln -sfn $(shell pwd)/envs/$(e)/_variables.tf $(shell pwd)/$$service && \
		if grep -w ".gitignore" -e "$$service/$$VAR"; then \
			echo "Do not need to add this symlink to .gitignore"; \
		else \
			find $$service -type l >> .gitignore && \
			echo Add \"$$service/_variables.tf\" symlink to .gitignore; \
		fi \
	done
#Unsymlink: When deleting service
.PHONY: unsymlink
unsymlink: check_env check_service
	@service_path=$$(ls -dl envs/$(e)/* | grep '^d' | grep $(s) | head -n 1 | grep -o '[^ ]*$$') && VAR="_variables.tf" && \
	if grep -w ".gitignore" -e "$$service_path/$$VAR"; then \
		sed -i '' $$(grep -nw ".gitignore" -e "$$service_path/$$VAR" | cut -c -1)d .gitignore && \
		rm -rf $$service_path/$$VAR && \
		echo Unsymlink and remove \"$$service_path/_variables.tf\" to .gitignore; \
	else \
		echo \"$$service_path/_variables.tf\" unsymlinked; \
	fi \

.PHONY: unsymlink_all
unsymlink_all: check_env
	@service_path=$$(ls -dl envs/$(e)/* | grep '^d' | grep -o '[^ ]*$$') && VAR="_variables.tf" && \
	for service in $$service_path; do \
		if grep -w ".gitignore" -e "$$service/$$VAR"; then \
			sed -i '' $$(grep -nw ".gitignore" -e "$$service/$$VAR" | cut -c -1)d .gitignore && \
			rm -rf $$service/$$VAR && \
			echo Unsymlink and remove \"$$service/_variables.tf\" to .gitignore; \
		else \
			echo \"$$service/_variables.tf\" unsymlinked; \
		fi \
	done


#Init commands
.PHONY: init
init: check_env check_service
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting init: \"$$service_path\" && \
	terraform -chdir=$$service_path init

.PHONY: init_upgrade
init_upgrade: check_env check_service
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting init upgrade: \"$$service_path\" && \
	terraform -chdir=$$service_path init --upgrade

.PHONY: init_migrate
init_migrate: check_env check_service
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting init migrate-state: \"$$service_path\" && \
	terraform -chdir=$$service_path init -migrate-state

.PHONY: init_all
init_all: check_env
	@service_path=$$(ls -d envs/$(e)/*/) && \
	for service in $$service_path; do \
		echo Excuting init: \"$$service\" && \
		terraform -chdir=$$service init; \
	done


#Plan/Apply commands
.PHONY: plan
plan: check_env check_service
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting plan: \"$$service_path\" && \
	terraform -chdir=$$service_path plan --var-file=../terraform.$(e).tfvars

.PHONY: plan_target
plan_target: check_env check_service check_target
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting plan: \"$$service_path\" with target: \'$(t)\' && \
	terraform -chdir=$$service_path plan --var-file=../terraform.$(e).tfvars --target '$(t)'

.PHONY: plan_all
plan_all: check_env
	@service_path=$$(ls -d envs/$(e)/*/) && \
	for service in $$service_path; do \
		echo Excuting plan: \"$$service\" && \
		terraform -chdir=$$service plan --var-file=../terraform.$(e).tfvars; \
	done

.PHONY: plan_cicd
plan_cicd: check_env
	@service_path=$$(ls -d envs/$(e)/*/) && \
	for service in $$service_path; do \
		echo Excuting CICD: \"$$service\" && \
		terraform -chdir=$$service plan --var-file=../terraform.$(e).tfvars -no-color; \
	done

.PHONY: apply
apply: check_env check_service
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting apply: \"$$service_path\" && \
	terraform -chdir=$$service_path apply --var-file=../terraform.$(e).tfvars

.PHONY: apply_target
apply_target: check_env check_service check_target
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting apply: \"$$service_path\" with target: \'$(t)\' && \
	terraform -chdir=$$service_path apply --var-file=../terraform.$(e).tfvars --target '$(t)'

.PHONY: apply_all
apply_all: check_env
	@service_path=$$(ls -d envs/$(e)/*/) && \
	for service in $$service_path; do \
		echo Excuting apply: \"$$service\" && \
		terraform -chdir=$$service apply --var-file=../terraform.$(e).tfvars; \
	done

.PHONY: apply_cicd
apply_cicd: check_env
	@service_path=$$(ls -d envs/$(e)/*/) && \
	for service in $$service_path; do \
		echo Excuting apply: \"$$service\" && \
		terraform -chdir=$$service apply --var-file=../terraform.$(e).tfvars -auto-approve; \
	done


#Plan/Destroy commands
.PHONY: plan_destroy
plan_destroy: check_env check_service
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting plan destroy: \"$$service_path\" && \
	terraform -chdir=$$service_path plan --var-file=../terraform.$(e).tfvars -destroy

.PHONY: plan_destroy_target
plan_destroy_target: check_env check_service check_target
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting plan destroy: \"$$service_path\" with target: \'$(t)\' && \
	terraform -chdir=$$service_path plan --var-file=../terraform.$(e).tfvars --target '$(t)' -destroy

.PHONY: plan_destroy_all
plan_destroy_all: check_env
	@service_path=$$(ls -dr envs/$(e)/*/) && \
	for service in $$service_path; do \
		echo Excuting plan destroy: \"$$service\" && \
		terraform -chdir=$$service plan --var-file=../terraform.$(e).tfvars -destroy; \
	done

.PHONY: destroy
destroy: check_env check_service
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting destroy: \"$$service_path\" && \
	terraform -chdir=$$service_path destroy --var-file=../terraform.$(e).tfvars

.PHONY: destroy_target
destroy_target: check_env check_service check_target
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting destroy: \"$$service_path\" with target: \'$(t)\' && \
	terraform -chdir=$$service_path destroy --var-file=../terraform.$(e).tfvars --target '$(t)'

.PHONY: destroy_all
destroy_all: check_env
	@service_path=$$(ls -dr envs/$(e)/*/) && \
	for service in $$service_path; do \
		echo Excuting destroy: \"$$service\" && \
		terraform -chdir=$$service destroy --var-file=../terraform.$(e).tfvars; \
	done

#Other commands
##Recreate resource
.PHONY: taint
taint: check_env check_service check_target
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting taint resource: \"$$service_path\" with target: \'$(t)\' && \
	terraform -chdir=$$service_path taint '$(t)'

.PHONY: untaint
untaint: check_env check_service check_target
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting untaint resource: \"$$service_path\" with target: \'$(t)\' && \
	terraform -chdir=$$service_path untaint '$(t)'

##State of resource
.PHONY: state_list
state_list: check_env check_service
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting state list resource: \"$$service_path\" && \
	terraform -chdir=$$service_path state list

.PHONY: state_show
state_show: check_env check_service check_target
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting state show resource: \"$$service_path\" with target: \'$(t)\' && \
	terraform -chdir=$$service_path state show '$(t)'

.PHONY: state_import
state_import: check_env check_service check_target check_other_target
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting state import resource: \"$$service_path\" from target: \'$(t)\' to: $(ot) && \
	terraform -chdir=$$service_path import --var-file=../terraform.$(e).tfvars '$(t)' '$(ot)'

.PHONY: state_rm
state_rm: check_env check_service check_target
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting state delete resource: \"$$service_path\" with target: \'$(t)\' && \
	terraform -chdir=$$service_path state rm '$(t)'

.PHONY: state_mv
state_mv: check_env check_service check_target check_other_target
	@service_path=$$(ls -d envs/$(e)/*/ | grep $(s) | head -n 1) && echo Excuting state move resource: \"$$service_path\" from target: \'$(t)\' to: \'$(ot)\' && \
	terraform -chdir=$$service_path state mv '$(t)' '$(ot)'

.PHONY: validate_cicd
validate_cicd: check_env
	@service_path=$$(ls -d envs/$(e)/*/) && \
	for service in $$service_path; do \
		echo Excuting validate: \"$$service\" && \
		set -euf -o pipefail; terraform -chdir=$$service validate; \
	done

.PHONY: fmt_cicd
fmt_cicd: check_env
	@service_path=$$(ls -d envs/$(e)/*/) && \
	for service in $$service_path; do \
		echo Excuting fmt: \"$$service\" && \
		terraform -chdir=$$service fmt; \
	done

.PHONY: tflint_config_all
tflint_config_all: check_env
	@service_path=$$(ls -dl envs/$(e)/* | grep '^d' | grep -o '[^ ]*$$') && VAR=".tflint.hcl" && \
	for service in $$service_path; do \
		ln -sfn $(shell pwd)/envs/$(e)/.tflint.hcl $(shell pwd)/$$service && \
		if grep -w ".gitignore" -e "$$service/$$VAR"; then \
			echo "Do not need to add this tflint config to .gitignore"; \
		else \
			find $$service -type l >> .gitignore && \
			echo Add \"$$service/.tflint.hcl\" tflint config to .gitignore; \
		fi \
	done

.PHONY: tflint_init_all
tflint_init_all: check_env
	@service_path=$$(ls -d envs/$(e)/*/) && \
	for service in $$service_path; do \
		echo Excuting tflint init: \"$$service\" && \
		tflint --init --chdir=$$service; \
	done

.PHONY: tflint_all
tflint_all: check_env
	@service_path=$$(ls -d envs/$(e)/*/) && \
	for service in $$service_path; do \
		echo Excuting tflint: \"$$service\" && \
		set -euf -o pipefail; tflint --call-module-type=all --chdir=$$service; \
	done

.PHONY: tfsec_all
tfsec_all: check_env
	@service_path=$$(ls -d envs/$(e)/*/) && \
	for service in $$service_path; do \
		echo Excuting tfsec: \"$$service\" && \
		tfsec $$service  --config-file tfsec.yml --no-color --format=json; \
	done