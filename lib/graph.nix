## Graph helpers over adjacency maps: { <node> = [ <successor> ... ]; }.
## Edges to unknown nodes are ignored here; dangling references are reported
## separately by the reference assertions.
{lib}: let
  inherit (builtins) attrNames elem filter;

  ## Nodes that sit on or behind a cycle, or [] for a DAG.
  ## Uses lib.toposort, so `edges.<a>` lists the nodes that must come after a.
  cyclicNodes = edges: let
    nodes = attrNames edges;
    sorted = lib.toposort (a: b: elem b (edges.${a} or [])) nodes;
    ## toposort never compares a node with itself, so self-loops need their own check.
    selfLoops = filter (n: elem n edges.${n}) nodes;
  in
    lib.unique (
      selfLoops
      ++ (
        if sorted ? result
        then []
        else sorted.cycle ++ sorted.loops
      )
    );

  ## Nodes reachable from `start` (inclusive), breadth-first.
  reachable = edges: start: let
    step = seen: frontier:
      if frontier == []
      then seen
      else let
        next = lib.unique (filter (n: !(elem n seen)) (lib.concatMap (n: edges.${n} or []) frontier));
      in
        step (seen ++ next) next;
  in
    step [start] [start];
in {
  inherit cyclicNodes reachable;
}
