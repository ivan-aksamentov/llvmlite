#!/bin/bash

CONDA_INSTALL="conda install -q -y"
PIP_INSTALL="pip install -q"

# Deactivate any environment
set +v
source deactivate
set -v
# Display root environment (for debugging)
conda list
# Clean up any left-over from a previous build
# (note workaround for https://github.com/conda/conda/issues/2679:
#  `conda env remove` issue)
conda remove --all -q -y -n $CONDA_ENV
# Scipy, CFFI, jinja2 and IPython are optional dependencies, but exercised in the test suite
if [ "$PYTHON" == "pypy" ]; then
    conda create -c gmarkall -n $CONDA_ENV -q -y pypy
else
    conda create -n $CONDA_ENV -q -y python=$PYTHON
fi

set +v
source activate $CONDA_ENV
set -v

# Install llvmdev (separate channel, for now)
$CONDA_INSTALL -c numba llvmdev="4.0*"

# Install enum34 for Python < 3.4 and PyPy, and install dependencies for
# building the docs. Sphinx 1.5.4 has a bug.
if [ "$PYTHON" == "pypy" ]; then
  python -m ensurepip
  $PIP_INSTALL enum34
  $PIP_INSTALL sphinx==1.5.1 sphinx_rtd_theme pygments
else
  $CONDA_INSTALL sphinx=1.5.1 sphinx_rtd_theme pygments
  if [ "$PYTHON" \< "3.4" ]; then
    $CONDA_INSTALL enum34
  fi
fi

# Install dependencies for code coverage (codecov.io)
if [ "$RUN_COVERAGE" == "yes" ]; then $PIP_INSTALL codecov coveralls; fi
