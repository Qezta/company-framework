## Shared assertion builders, so every module words failures the same way
## (negative tests match on these messages).
{lib}: rec {
  check = assertion: message: {inherit assertion message;};

  refersTo = ids: what: kind: ref:
    check (builtins.elem ref ids) "${what} references unknown ${kind} '${ref}'";

  ## Ownership: present and resolvable.
  owner = roleIds: what: o:
    if o == ""
    then [(check false "${what} has no owner")]
    else [(refersTo roleIds "${what} owner" "role" o)];

  ## A Markdown file relative to company.root, checked only when root is set.
  docExists = root: what: doc:
    lib.optional (root != null && doc != null)
    (check (builtins.pathExists (root + "/${doc}")) "${what} doc does not exist: '${doc}'");
}
