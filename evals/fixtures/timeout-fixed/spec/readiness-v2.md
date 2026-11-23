# Readiness API, protocol revision 2

**Status:** current. This specification supersedes revision 1.

A readiness request has a fixed API deadline of **30 seconds**. The API deadline is the same for every caller. It is a limit on the request, not a guarantee of a successful response. Clients can stop waiting earlier on their own.

`public/timeout-policy.txt` publishes the active policy. The offline reference command `sh bin/request-deadline.sh [positive-seconds]` resolves the deadline for one request.
