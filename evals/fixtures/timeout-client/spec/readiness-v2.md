# Readiness API, protocol revision 2

**Status:** current. This specification supersedes revision 1.

The caller chooses the deadline for each readiness request. Omitting the caller's deadline leaves it unset. The API guarantees no fixed timeout and supplies no numeric default.

`public/timeout-policy.txt` publishes the active policy. The offline reference command `sh bin/request-deadline.sh [positive-seconds]` resolves the deadline for one request.
