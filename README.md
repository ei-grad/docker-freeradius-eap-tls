# Docker FreeRADIUS EAP-TLS

Opionated Docker image to setup a FreeRADIUS server configured for EAP-TLS
authentication. EAP-TLS provides strong security through client and server
certificates. This setup features a custom minimal FreeRadius configuration
suitable only for EAP-TLS auth with a single CA certificate and OCSP for
certificate revokation.

## Usage

### Prerequisites

- Recent version of Docker installed on your system.

> [!NOTE]
> The Dockerfile relies on the BuildKit. Use pre-built image if you have
> problems.

- Set up PKI and method to issue/distribute client certificates (and generate
  one / a couple for the radius server).

### Certificates for server

Ensure your server certificate, its private key, and CA certificate files are
placed into the `certs/` directory and are properly named:
- `certs/server.crt`
- `certs/server.key`
- `certs/ca.crt`

### Config

Config files used by `freeradius-eap-tls` image by default are located at `/conf`.

> [!NOTE]
> In Ubuntu, FreeRadius config lives in `/etc/freeradius/3.0`, we just ignore
> it, you can refer there if you want. But better use
> [man pages](https://freeradius.org/radiusd/man/radiusd.conf.html) or
> [online docs](https://freeradius.org/radiusd/man/radiusd.conf.html).

Put this settings in the file named `custom.conf`:

```conf
# specify the password used to encrypt `certs/server.key`
private_key_password = whatever

client ap {
    # replace with address or network of your access point(s)
    ipaddr = 192.168.1.1/32
    # shared secret specified in the access point's Radius connection settings
    secret = testing123
}

#client ap2 {
#    ipaddr = ...
#    secret = ...
#}

# replace `example.org` to the domain used in certificates common names
realm example.org {
}
```

If you desire, corresponding config files could be written into
`/conf/mods-enabled`, `/conf/sites-enabled` or `/conf/policy.d`. Refer to the
structure of [radiusd.conf](./conf/radiusd.conf). Though, additional
configuration shouldn't be needed, if your goal is just to setup the WPA2/3
Enterprise with EAP-TLS.

### Permissions

Ubuntu uses `freerad` user with `uid=100` and `gid=101` to run FreeRadius. We
use it also.

> [!IMPORTANT]
> Ensure `100:101` could read the configs, certificates and server private key.

```
```

### Run

```bash
chown -R 100:101 certs custom.conf
docker run -d --name freeradius-eap-tls \
    -p 1812:1812/udp \
    -v $PWD/custom.conf:/conf/custom.conf \
    -v $PWD/certs:/conf/certs \
    eigrad/freeradius-eap-tls

# or just
#docker compose up -d
```

### Configure test WiFi network and check the connection

To test that the FreeRADIUS server is functioning correctly with EAP-TLS authentication:

1. Configure a WiFi access point or router to use WPA2/WPA3 Enterprise security.
   - Set the security mode to WPA2/WPA3 Enterprise.
   - Enter the Radius server IP (the Docker host IP) and port 1812.
   - Specify the shared secret configured in `custom.conf`.

2. Configure a client device WiFi settings to connect to the test SSID.
   - Select the test SSID.
   - Set security to WPA2/WPA3 Enterprise.
   - Select EAP-TLS mode (on iPhone you have to add a client certificate to the system first)
   - Select the client certificate
   - Accept CA certificate trust pop-up

4. Attempt to connect to the WiFi.

5. Check Docker logs to see if there are problems.

### Debug output

You may want to remove `-X` flag from the command, to reduce debug output while
running FreeRadius in production.

## Contributing
Contributions are welcome. Please follow best practices and update the
documentation as needed.

## License
This project is licensed under the MIT License. See the LICENSE file for more
details.
