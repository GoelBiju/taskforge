PYTHON := python3
PIP := $(PYTHON) -m pip

lint:
	$(PYTHON) -m pydocstyle src
	$(PYTHON) -m pylint src tests

fmt:
	$(PYTHON) -m yapf --recursive -i src tests

clean:
	rm -rf build dist
	rm -rf {} **/*.egg-info
	rm -f **/*.pyc

install:
	$(PYTHON) setup.py install

install-dev:
	$(PIP) install --editable .
	$(PIP) install --editable ".[mongo]"
	$(PIP) install -r requirements.dev.txt

test:
	PYTHONPATH="$$PYTHONPATH:src" $(PYTHON) -m pytest -m 'not slow'

test-all:
	PYTHONPATH="$$PYTHONPATH:src" $(PYTHON) -m pytest --disable-pytest-warnings

publish: clean
	python setup.py sdist bdist_wheel
	twine upload dist/*

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SOURCEDIR     = src/docs
BUILDDIR      = docs

.PHONY: docs
docs: html
	rm -rf docs/*
	mv build/docs/html/* docs/

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

livehtml:
	sphinx-autobuild --watch ./src -b html $(SPHINXOPTS) "$(SOURCEDIR)" $(BUILDDIR)/html

# Build the web site container
website: html
	docker build --tag "chasinglogic/taskforge.io:latest" --file Dockerfile.website .

publish-website: website
	docker push "chasinglogic/taskforge.io:latest"

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
