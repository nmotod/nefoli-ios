default-target: help

SWIFTFORMAT = cd BuildTools && swift run swiftformat
ARGS = $(filter-out $@,$(MAKECMDGOALS))

export
LOCALIZATION_DIR = ./Localizations
LANGUAGES = en ja
MODULES = Root Database TabBrowser Theme Utils

## help
.PHONY: help
help:
	@echo 'Commands:'
	@sed -n 's/^## /  /p' ${MAKEFILE_LIST}

## edit (e)
.PHONY: edit e
edit e:
	xed .
	
## swiftformat (f)
.PHONY: swiftformat format f
swiftformat f:
	$(SWIFTFORMAT) $(ARGS) ..

## swiftformat-lint (l)
##   Lint using SwiftFormat
.PHONY: swiftformat-lint l
swiftformat-lint l:
	$(SWIFTFORMAT) --lint --lenient $(ARGS) "$(PWD)"

.PHONY: export-loc
export-loc:
	xcodebuild \
		-exportLocalizations \
		-quiet \
		-localizationPath $(LOCALIZATION_DIR) \
		-sdk "$(shell xcrun --sdk iphoneos --show-sdk-path)" \
		$(shell for lang in $(LANGUAGES); do echo -exportLanguage "$$lang"; done)

.PHONY: import-loc
import-loc:
	@for lang in $(LANGUAGES); do \
		echo "Importing $$lang"; \
		xcodebuild \
			-importLocalizations -quiet \
			-localizationPath "$(LOCALIZATION_DIR)/$$lang.xcloc/Localized Contents/$$lang.xliff" \
			-sdk "$(shell xcrun --sdk iphoneos --show-sdk-path)" \
			; \
	done

.PHONY: edit-loc
edit-loc:
	open "$(LOCALIZATION_DIR)/$(filter-out $@,$(MAKECMDGOALS)).xcloc"

.PHONY: $(LANGUAGES)
$(LANGUAGES):
	@:

.PHONY: $(MODULES)
$(MODULES):
	@:

%:
	@:
