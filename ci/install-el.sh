#!/bin/bash
# Copyright (C) Duncan Macleod (2017)
#
# This file is part of GWpy.
#
# GWpy is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# GWpy is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GWpy.  If not, see <http://www.gnu.org/licenses/>.

#
# Build RedHat (Enterprise Linux) packages
#

# update system
yum clean all
yum makecache
yum -y update
yum -y install rpm-build git2u python-jinja2 ${PY_PREFIX}-jinja2

GWPY_VERSION=`python setup.py version | grep Version | cut -d\  -f2`

# upgrade setuptools for development builds only to prevent version munging
if [[ "${GWPY_VERSION}" == *"+"* ]]; then
    pip install "setuptools>=25"
fi

# upgrade GitPython (required for git>=2.15.0)
pip install "GitPython>=2.1.8"

# build the RPM
python setup.py bdist_rpm

# install the rpm
if [ ${PY_XY} -lt 30 ]; then
    GWPY_RPM="dist/python2-gwpy-*.noarch.rpm"  # install python2 only
else
    GWPY_RPM="dist/python*-gwpy-*.noarch.rpm"  # install both 2 and 3
fi
yum -y --nogpgcheck localinstall ${GWPY_RPM}

# install system-level extras
yum -y install \
    nds2-client-${PY_PREFIX} \
    ldas-tools-framecpp-${PY_PREFIX} \
    lalframe-${PY_PREFIX} \
    lalsimulation-${PY_PREFIX} \
    h5py \
|| true

# install system-level extras that might use python2- prefix
if [ ${PY_XY} -lt 30 ]; then
    yum -y install python2-root
else
    yum -y install ${PY_PREFIX}-root
fi

# install root_numpy
NO_ROOT_NUMPY_TMVA=1 ${PIP} install root_numpy ${PIP_FLAGS}
