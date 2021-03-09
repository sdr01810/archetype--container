#!/bin/bash
##
## Typical use:
## 
##     docker-logs-follow-until 'STATE: RUNNING' ${container_id}
##

set -e

set -o pipefail

##
## core logic:
## 

completion_regex="${1:?missing value for completion_regex}" ; shift 1

container_id="${1:?missing value for container_id}" ; shift 1

python3 <<-END

	import sys
	import pexpect

	session = pexpect.spawn(

	    'docker', [ 'logs', '-f', '${container_id:?}' ],

	    logfile = sys.stdout.buffer, echo = False,
	)

	interaction_points = [

	    pexpect.EOF,                    # 0

	    pexpect.TIMEOUT,                # 1

	    '\r\n[+] :',                    # 2

	    '\r\n${completion_regex}',      # 3
	]

	xc_success = 0
	xc_failure = 2

	xc = xc_success # until proven otherwise

	interaction_interval_max = 2 * 60.0 # seconds

	while 1:

	    try:
	        i = session.expect(interaction_points, timeout = interaction_interval_max)

	    except Exception as x:
	        print("Interaction exception:")
	        print(e)
	        print("Interaction state:")
	        print(str(installation))
	        exit(xc_failure)

	    if 0: pass
	    elif i == 0: # eof
	        xc = xc_failure
	        break

	    elif i == 1: # timeout
	        xc = xc_failure
	        break

	    elif i == 2: # progressing
	        pass

	    elif i == 3: # complete
	        xc = xc_success
	        break

	session.close()

	exit(xc)
END

