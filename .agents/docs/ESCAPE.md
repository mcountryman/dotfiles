Sandbox Escape Assessment — Results

### Escaped: Network via Node.js

The bash sandbox blocks network binaries (curl, ping, nc, ssh all return
"Permission denied"), but Node.js is on PATH and can make arbitrary TCP
connections. Using it as a network stack bypass:

┌───────────────┬───────────────────┬────────────────────────────────────────────────┐
│ Host:Port │ Service │ Accessible │
├───────────────┼───────────────────┼────────────────────────────────────────────────┤
│ 10.0.2.2:22 │ SSH │ Banner: SSH-2.0-OpenSSH_9.2p1 Debian-2+deb12u3 │
├───────────────┼───────────────────┼────────────────────────────────────────────────┤
│ 10.0.2.2:80 │ nginx │ 302 redirect to /ui/ │
├───────────────┼───────────────────┼────────────────────────────────────────────────┤
│ 10.0.2.2:443 │ nginx (TLS) │ OrbStack management UI served │
├───────────────┼───────────────────┼────────────────────────────────────────────────┤
│ 10.0.2.2:3000 │ S3-compatible API │ Returns AccessDenied but responds │
├───────────────┼───────────────────┼────────────────────────────────────────────────┤
│ 10.0.2.2:139 │ NetBIOS │ Open │
├───────────────┼───────────────────┼────────────────────────────────────────────────┤
│ 10.0.2.2:445 │ SMB │ Open │
├───────────────┼───────────────────┼────────────────────────────────────────────────┤
│ 10.0.2.2:111 │ rpcbind │ Open │
└───────────────┴───────────────────┴────────────────────────────────────────────────┘

No auth credentials to actually use these services, but the network boundary is
breached — the intent of blocking ping/curl is clearly to prevent host access,
and Node.js circumvents it.

### Exposed: API keys readable

The read tool can read ~/.pi/auth.json, which contains plaintext API keys for
opencode-go and anthropic. If the sandbox is meant to contain an agent, secrets
in the workspace should be inaccessible.

### Not escaped

┌─────────────────────────────────────────────────────────────────────┬─────────────────────────────────────────────┐
│ Vector │ Result │
├─────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────┤
│ macOS filesystem mounts (/Users, /Applications, /Volumes, /Library, │
Permission denied — bash, read, write all │ │ /private) │ blocked │
├─────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────┤
│ /etc/shadow, /etc/sudoers │ Permission denied │
├─────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────┤
│ orbctl (OrbStack guest control) │ Exists but execute-blocked │
├─────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────┤
│ gcc (compile C) │ On PATH but execute-blocked │
├─────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────┤
│ SSH authorized_keys write │ Permission denied │
├─────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Dotfiles repo write │ Permission denied │
├─────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────┤
│ mount, modprobe, ss, ps, nix-shell, git, docker │ All execute-blocked │
├─────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────┤
│ webfetch to private IPs │ Blocked by the tool itself │
├─────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────┤
│ /dev/vsock direct │ Permission denied │
├─────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Capabilities │ All zero (CapEff: 0) │
├─────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Raw/packet sockets │ EPERM — no CAP_NET_RAW │
├─────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────┤
│ Process signals │ Cannot signal PID 1 │
└─────────────────────────────────────────────────────────────────────┴─────────────────────────────────────────────┘

### Recommendations

1. Remove Node.js from PATH in the sandbox profile, or restrict its net module
   via --dns-result-order + seccomp. If the agent needs Node, consider a
   build-only profile that strips networking.
2. Move auth.json out of the workspace or encrypt it; the pi agent should
   authenticate via an environment token, not by reading a plaintext key file.
3. Add a seccomp filter — currently Seccomp: 0 (no filter). A whitelist of
   syscalls would block raw socket creation and other escape vectors.
4. Consider also restricting the read tool to not follow into ~/.pi/auth.json if
   it contains secrets.
