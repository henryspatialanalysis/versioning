## #######################################################################################
##
## Package maintenance makefile
##
## #######################################################################################

R_EXEC := /usr/bin/R --no-save --quiet

# Build package
build:
	@$(R_EXEC) -e "devtools::build()"

# Build and install package
install:
	@$(R_EXEC) -e "devtools::install()"

# Build man pages
build-docs:
	@$(R_EXEC) -e "devtools::document()"

# Check package for CRAN
check:
	@$(R_EXEC) -e "devtools::check(cran = TRUE)"

# Convenience target to print all of the available targets in this file
# From https://stackoverflow.com/questions/4219255
.PHONY: list
list:
	@LC_ALL=C $(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | \
		awk -v RS= -F: '/^# File/,/^# Finished Make data base/ \
		{if ($$1 !~ "^[#.]") {print $$1}}' | \
		sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
