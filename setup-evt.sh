#!/bin/bash
deactivate 2>/dev/null
python -m venv myenv && \
source myenv/bin/activate && \
export PATH="$PATH:." && \
chmod 775 ./evt && \
pip3 install gitpython simplejson
