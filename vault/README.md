# Vault

Vault is a secrets engine created by Hashicorp. It provides lots of different capabilities from dynamic secrets to 
one time passwords to an online encryption API. Vault also has a mature docker container which runs Vault in development 
mode. Development mode allows developers to set the root Vault token and starts unsealed (More information on that concept 
here: https://www.vaultproject.io/docs/concepts/seal) but it also uses an in memory data store which disappears after 
service restart. This is great for integration testing or for testing a specific usage because it forces you to develop
your automation. It also ensures that if you do accidentally put production like secrets into your dev Vault it will disappear
as soon as it shuts down.

Below I'll describe how you could setup Vault locally
TL;DR:

Paste this into your terminal to just have a non TLS Vault described in this article. Link [here] for a Docker Compose file.
```
# mkdir -p {config,data,logs}
# cat > config/vault.hcl <<EOF
ui = true
listener "tcp" {
    address = "0.0.0.0:8200"
    telemetry {
        unauthenticated_metrics_access = "true"
    }
    tls_disable = 1
}

storage "file" {
    path = "/vault/data"
}


api_addr = "http://0.0.0.0:8200"
cluster_addr = "http://0.0.0.0:8200"
EOF
# docker run -d \
  -p 127.0.0.1:8200:8200 -p 127.0.0.1:8201:8201 \
  -v $PWD/logs:/vault/logs \
  -v $PWD/data:/vault/file \
  -v $PWD/config:/vault/config \
  --cap-add=IPC_LOCK --restart=always \
  --name=vault vault vault server -config=/vault/config
# docker exec vault vault operator init
```

## Configuration for a local Vault

```
ui = true
listener "tcp" {
    address = "0.0.0.0:8200"
    telemetry {
        unauthenticated_metrics_access = "true"
    }
    tls_disable = 1
}

storage "file" {
    path = "/vault/data"
}


api_addr = "http://0.0.0.0:8200"
cluster_addr = "http://0.0.0.0:8200"
```

### With TLS

Many people might say that since this is being accessed over localhost you don't need to worry about TLS
encryption but just because no one can access it directly doesn't mean that your browser can't. And if your 
browser can access something then so can the rest of the internet. You can [read](https://www.pentestpartners.com/security-blog/lan-surfing-how-to-use-javascript-to-execute-arbitrary-code-on-routers/) [some](https://portswigger.net/research/exposing-intranets-with-reliable-browser-based-port-scanning) [examples]( if you don't 
belive me.

```
ui = true
listener "tcp" {
    address = "0.0.0.0:8200"
    tls_cert_file = "/vault/config/tls.crt"
    tls_key_file = "/vault/config/tls.key"
    unauthenticated_metrics_access = "true"
}

storage "file" {
    path = "/vault/data"
}

api_addr = "https://0.0.0.0:8200"
cluster_addr = "https://0.0.0.0:8200"
```

### Where do the certs come from?

My suggestion, especially for something that runs locally is to use [mkcert](https://github.com/FiloSottile/mkcert)
which will install and create certificates for local services

## Initializing Vault

Now that you have Vault up and running you can initialize Vault. The
easiest way to do this is via `vault operator init` which will initialize 
Vault. Then you'll want to save the unseal keys and root token for later

```
  --> vault operator init 
Unseal Key 1: SPAFDZFdJ+tvKAXljuJaKjxAxnKY+TlssAdqGEPFlVWX
Unseal Key 2: qMyLDzptS5jLU6vmqkGpCVZirU9LignvWovg1xdCqnbM
Unseal Key 3: EI5Ts5DNm04vEbnCUqb5v+WTNWAPDlRH1p0EzaLlA6BY
Unseal Key 4: kFV5NwVunFw4peE7ctc9BDyOMJzUnGrYyIIiFeETb0gi
Unseal Key 5: WpZHdbfgRLqxSnLV13jqBMoBekv/YOFeRiaevDIiABVv

Initial Root Token: s.J6Pub6opZmTxggPvIyKtvtJW

Vault initialized with 5 key shares and a key threshold of 3. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 3 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 3 key to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.
```

If you have a keybase account you can have Vault automatically fetch the 
pgp key from keybase. Unfortunately you need the same number of unseal 
keys as you do pgp keys. Since this is a "personal" Vault this means that 
you only have 1 unseal key. Again this is a "personal" Vault and you only
have 1 person to distribute your keys to so that's fine.

```
  --> vault operator init -key-shares=1 -key-threshold=1 -pgp-keys=keybase:clly -root-token-pgp-key=keybase:clly
Unseal Key 1: wcFMA/a2+zEVql0rARAAQ1R3VSQ0aG7lMQaBmmDKlhSdCu8PDmISxwh0XT9odjLg1AScURPeaS3H6bqW1XBwrvigg0PTUrF5tMUa9s7CE3F9vxGQialFZ+AuyLt/6BQ5d67vM8Fo6NGppIIuav7qWIsJlsWDfUl2xOqAfxSbvHyTr+AZZLFMQfVjCbIjaL3hZ082fvvvMGqYbGvPeQ2OxsvhDJliV0Sb6+GMXRZ4KWCgTDKs0C8LtmuQEeLQuBwq78fnjp1jTNJNMQNHVtjXeDHmueUqtR6lA2dYV8xNQaGSzMmvU3DqkcjzfivDg5in6UTekL7MK7ITPgP8R4+pWYRx3BkHumAGOW03opjYv34/dsL4/biavZuULqXzKjhHDiBikiwF8bSuEZH65NNyoe9ZeMddzZM4kygCgoXkYxaAuUGElBuZF/koHUjOK/BCP2987JcP2PyCmPmxpJcGJSncX7nEDK6O27oUldqWQm6xJ8i3jwnMs9xNAGcUvrDkVJ/0/sauFUXMriKPkhHx30UX2oHEVNgNXuVzRFEBJrbuzG9tPhjUrhUi//Nh6r/r9xd7bTVG2meUtQOwNg5x4ONGREoQSHzBKL5o+lSDg+hxlh/RoSoOkD3WFCooCaI68bMPGCgitzXC3gYODUceQjS/AZQqskZ56tLJZAvrCwssxs1+GP6YkpwUQFkXoHzS4AHkALtu1rCt7pixVU5pm/HsBuGCw+DW4PHh/CLgU+LNWrWs4D3mmtJSANwb9QfeYEAiB7Ju6DBpg2PgJQnwfArQt2hqLYJN54rJ9EnAKc/Cu3/mjctW5TZPCgxX4cYLcWGHyxY0R+Ci5OkuBBJPBrE9sHLYqKICwnXiECAeoeEGZwA=

Initial Root Token: wcFMA/a2+zEVql0rARAAwmjD57pUhPKzXdYh0sdCcJJZjSP3emTEFxX0NhC8oIFNqsKnOxDI+pKK0gzpYdySSBpdVFdByxl0rcDBY8yuccQZRM7LjQQMe7hyn2FxNtk9zSA3QjINhx+0aKcwlISqosf71QNYVXiVMH7wmbu+NsVWvdIQV3eIqx81yezgFjpPFAHgVaiTdzs4YhQyz98TvRsBawYRA4HVgZ39YvTYA8JH0ubg5jDDwGyF70X4RjCyIGOp6p5T1ta6W1l/D0ioYxkU483GWSGUI7ccxWC0uYMx3Arn/M56MPW+Xprj+LgmaPtarvTeLPtke0cEXZeIPPsJ43x6LE5Mu6az03AacSLmAdlfZk2ls4kE8rUEa+TXrAg+i78UylG5ta7rC9Sl7OFTbhuSUV1n/K5B4jGWoP2t/zO3gYXbK+UBTobZA/GXRVII8kRwo0f2bHZCiG1YzMun3T6ADY4AqKhAyeJ5FDq5IhcGF2Qn+3ExWX4zCx3Au7o1JzqcWjshZzSuPdri2NdgMOd7QsEIt57E4TExqP0Mknjva4oOyA7llBu5ckvsrXvySQcNKo8JwlTgMJOLC7q8tVNwKdVTAg4n9M7O78hu5Wn8T4+nY58SUlHENMbzplvZsG9urt5P7nOlSHcKnyxZn4Vn19vVbbZuW0fAVMtPTERMacNYvwhlBBlD/azS4AHkeGC9vaUaWbjFFxNqXXP9Z+FO6+B54Kzhh0ngkuKhjYVa4CnkE02kufge1SXVl+sn2ZAl7ODr4w1PctgyEcu84GHhCZfgquRNWm2UYI4NVw/xls7PLy734gDFG47hi9AA

Vault initialized with 1 key shares and a key threshold of 1. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 1 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 1 key to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.
```

You would want to place these keys in a secure place depending on what you end
up using this Vault for. The more important the usage more secure you want it 
to be.

Some options include

* Keybase FS
* [age](hattps://github.com/FiloScottile/age)
* [envy](https://github.com/shoenig/envy)
* Lastpass
* 1password

### Unsealing Vault

Whenever you want to use your personal Vault and it's just been restarted
or if you've restarted your computer you need to unseal Vault. You would
need to fetch your unseal key, and use the `vault operator unseal` command
to make your Vault usable again.

I've written my own example using a combination of envy and keybase pgp below. 
I'll go through it step by step.

```
unseal() {
    unseal=$(envy exec dev-vault bash -c 'printenv UNSEAL|base64 -d|keybase pgp decrypt')
    curl -XPUT https://localhost:8200/v1/sys/unseal --data-binary @- <<<"{\"key\":\"$unseal\"}"
}
```

```
envy exec dev-vault
```

envy allows you to store encrypted secrets in a boltdb with the password stored in your keyring. It
then allows you to exec commands with the secrets stored as environment variables.

```
bash -c 'printenv UNSEAL|base64 -d|keybase pgp decrypt'
```

The commands that envy is executing aren't actually running in a shell which means that we need to 
execute bash in order to use the pipes in our function. The encrypted data is base64 encoded so we 
pipe to decode it then decrypt it with keybase.

```
curl -XPUT https://localhost:8200/v1/sys/unseal --data-binary @- <<<"{\"key\":\"$unseal\"}"
```

Once we have our unseal key we can now unseal our local Vault.

### Using the root token

We can do almost the same thing that we do with our unseal key to use our root token.

```
rvault () { 
    VAULT_TOKEN=$(envy exec dev-vault bash -c 'printenv ROOT|base64 -d|keybase pgp decrypt');
    VAULT_TOKEN=$VAULT_TOKEN vault "$@"
}
```

If you don't have Vault installed locally you'll want to swap the regular vault execution to a 
docker exec command. If you run Vault with TLS though you'll run into issues with an unknown authority 
inside the docker container. From there you have a couple choices
1) Turn off TLS verification via the `VAULT_SKIP_VERIFY` environment variable.
2) Copy the CA file into the config directory. Then you can set the`VAULT_CAPATH` environment variable to
the CA path.
3) Build your own container with the CA cert trusted.

```
rvault () { 
    VAULT_TOKEN=$(envy exec dev-vault bash -c 'printenv ROOT|base64 -d|keybase pgp decrypt');
    docker exec -e VAULT_TOKEN vault vault $@
}

```

# Wrap Up

Now you have a local Vault that you can use for personal projects or long term
testing. 

Next time we'll talk about authenticating to Vault via one of the many authentication
mechanisms and using identities to link authentication mechanisms together
