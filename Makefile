## #######################################################################################
##
## Package maintenance makefile
##
## #######################################################################################

# Build package
pkg-build:
	@R CMD build ./;

# Get latest built package
pkg-latest-version:
	@ls versioning*.tar.gz | tail -1;

# Install the latest package version locally
pkg-install:
	@R CMD build ./
	@R CMD INSTALL $$(ls versioning*.tar.gz | tail -1);

# Check package for CRAN
pkg-check:
	@R CMD build ./
	@R CMD check --as-cran $$(ls versioning*.tar.gz | tail -1);

# Convenience target to print all of the available targets in this file
# From https://stackoverflow.com/questions/4219255
.PHONY: list
list:
	@LC_ALL=C $(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | \
		awk -v RS= -F: '/^# File/,/^# Finished Make data base/ \
		{if ($$1 !~ "^[#.]") {print $$1}}' | \
		sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
