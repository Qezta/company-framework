## Unit tests for lib/ helpers, in lib.runTests form. An empty result means pass.
{
  lib,
  companyLib,
  base,
}: let
  inherit (companyLib) dates graph serialize;
in
  lib.runTests {
    testPrettyJSON = {
      expr = serialize.toPrettyJSON {
        b = [1 {c = null;}];
        a = {};
        s = "x\"y";
      };
      expected = ''
        {
          "a": {},
          "b": [
            1,
            {
              "c": null
            }
          ],
          "s": "x\"y"
        }
      '';
    };
    testYAMLQuotesAmbiguousScalars = {
      expr = serialize.toYAML {
        on = "yes";
        n = 1;
        list = [
          {
            a = true;
            b = [];
          }
          "x"
        ];
        "github.com/slug" = "o/r";
        empty = {};
      };
      ## "n" and "on" are YAML 1.1 booleans, so those keys get quoted.
      expected = ''
        empty: {}
        github.com/slug: "o/r"
        list:
          - a: true
            b: []
          - "x"
        "n": 1
        "on": "yes"
      '';
    };
    testLeapDay = {
      expr = map dates.isValid ["2024-02-29" "2026-02-29" "2000-02-29" "1900-02-29"];
      expected = [true false true false];
    };
    testMonthBounds = {
      expr = map dates.isValid ["2026-04-30" "2026-04-31" "2026-13-01" "2026-00-10" "2026-1-01"];
      expected = [true false false false false];
    };
    testLeadingZeros = {
      expr = dates.parse "2026-08-09";
      expected = {
        year = 2026;
        month = 8;
        day = 9;
      };
    };
    testDateOrder = {
      expr = [(dates.lessOrEqual "2026-01-31" "2026-02-01") (dates.lessOrEqual "2026-03-01" "2026-02-28")];
      expected = [true false];
    };
    testDagHasNoCycle = {
      expr = graph.cyclicNodes {
        a = ["b"];
        b = ["c"];
        c = [];
      };
      expected = [];
    };
    testCycleDetected = {
      expr = lib.sort (x: y: x < y) (graph.cyclicNodes {
        a = ["b"];
        b = ["a"];
        c = [];
      });
      expected = ["a" "b"];
    };
    ## Former people may still reference roles that were since deleted.
    testFormerKeepsDeletedRole = {
      expr =
        companyLib.failedAssertions
        (companyLib.evalCompany {
          modules = [
            base
            {
              company.people.olden = {
                displayName = "Old Timer";
                email = "old@acme.example";
                roles = ["deleted-role"];
                status = "former";
                endDate = "2026-01-01";
              };
            }
          ];
        })
        .config;
      expected = [];
    };
    testSelfLoopDetected = {
      expr = graph.cyclicNodes {
        a = ["a"];
        b = [];
      };
      expected = ["a"];
    };
    testReachable = {
      expr = lib.sort (x: y: x < y) (graph.reachable {
          a = ["b"];
          b = ["c"];
          c = [];
          d = ["a"];
        }
        "a");
      expected = ["a" "b" "c"];
    };
  }
