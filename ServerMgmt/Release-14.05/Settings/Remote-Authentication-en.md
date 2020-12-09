### Remote Authentication (ServiceConnect on CMIC only)

Remote authentication is a user service (RADIUS) networking protocol, operating on port 1812, providing authentication, authorization, and accounting management for users who use a network service.

**Host** - If the IP address is static, use it. Otherwise, use the name of the machine hosting the RADIUS server.

**Port** - The default RADIUS port is 1812. Change the value if you're using a different port.

**Accounting Port** - The default accounting port for RADIUS is 2813. Change the value if you're using a different accounting port.

**Request Retries** - 0 to 10.

**Request Timeout** - Type the number of seconds for the Agent to wait before the RADIUS server responds and the Agent retries the request.

**Shared Secret** - Type the shared secret that the RADIUS server uses to validate the Agent requesting the remote session.
