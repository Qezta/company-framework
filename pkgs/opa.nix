## open-policy-agent, except on x86_64-darwin: nixpkgs no longer caches it
## there and its upstream test suite fails to compile (v1/server tests,
## "undefined: fixture"), so build it without running those tests.
{
  open-policy-agent,
  stdenv,
}:
if stdenv.hostPlatform.system == "x86_64-darwin"
then open-policy-agent.overrideAttrs {doCheck = false;}
else open-policy-agent
