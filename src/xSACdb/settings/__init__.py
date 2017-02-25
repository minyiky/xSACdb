from __future__ import absolute_import, unicode_literals

import os

if 'XSACDB_ENVIRONMENT' in os.environ and os.environ['XSACDB_ENVIRONMENT'] == 'PRODUCTION':
    ENVIRONMENT = 'PRODUCTION'
    from .production import *
elif 'XSACDB_ENVIRONMENT' in os.environ and os.environ['XSACDB_ENVIRONMENT'] == 'TEST':
    ENVIRONMENT = 'TEST'
    from .test import *
else:
    ENVIRONMENT = 'DEVELOPMENT'
    from .development import *

# Club conf default inserter
from .defaults import CLUB as CLUB_DEFAULTS

for key, default_value in CLUB_DEFAULTS.iteritems():
    if not key in CLUB.keys():
        CLUB[key] = default_value

# Dirty fixes
ACCOUNT_EMAIL_SUBJECT_PREFIX = u'[{}] '.format(CLUB['name'])
