# Makefile
# Standard top-level shared Makefile switchboard to consolidate all common
# rules which will be used when testing or executing this repository.
#

####################
# Note: This file expects that it will be a single child directory below root.
# If the file needs to be stored in a lower directory, then add a `../` to the
# variable - REPO_DIR
####################
REPO_DIR=../
ROOT_DIR=${PWD}/${REPO_DIR}
PROJECT_DIR=${PWD}

# Auto-include the repository root Makefile to access shared resources
ifneq ("$(wildcard $(ROOT_DIR)/Makefile)", "")
	include $(ROOT_DIR)/Makefile
endif
ifneq ("$(wildcard $(ROOT_DIR)/Makefile.local)", "")
	include $(ROOT_DIR)/Makefile.local
endif
ifneq ("$(wildcard Makefile.local)", "")
	include Makefile.local
endif
