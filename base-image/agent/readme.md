- Create image agent

```powershell
podman build -t nuuvedevops/azdo-agents:linux-x64-agent-1.0.0 --build-arg Env_HttpProxy=proxy.mydomain.com:80 --build-arg Env_NoProxy=mydns.com
```