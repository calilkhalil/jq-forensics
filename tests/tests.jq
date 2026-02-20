# Test suite for jq-forensics
# Each test is a pipeline that should produce true if it passes

# Test fromwebkit
def test_fromwebkit:
  {
    name: "fromwebkit",
    tests: [
      (13318523932000000 | fromwebkit == "2012-03-15T10:12:12Z"),
      (0 | fromwebkit == null)
    ]
  } | .passed = ((.tests | [.[] | select(. == false)] | length) == 0);


# Test fromcocoa
def test_fromcocoa:
  {
    name: "fromcocoa",
    tests: [
      (978307200 | fromcocoa == "2001-01-01T00:00:00Z")
    ]
  } | .passed = ((.tests | [.[] | select(. == false)] | length) == 0);

# Test fromunix
def test_fromunix:
  {
    name: "fromunix",
    tests: [
      (1741420298 | fromunix == "2025-03-08T09:51:38Z"),
      (1741420298000 | fromunix == "2025-03-08T09:51:38Z"),
      (0 | fromunix == null)
    ]
  } | .passed = ((.tests | [.[] | select(. == false)] | length) == 0);

# Test toreadable
def test_toreadable:
  {
    name: "toreadable",
    tests: [
      ("2025-03-08T09:51:38Z" | toreadable == "2025-03-08 09:51:38"),
      (1741420298 | fromunix | toreadable == "2025-03-08 09:51:38")
    ]
  } | .passed = ((.tests | [.[] | select(. == false)] | length) == 0);

# Test todefang
def test_todefang:
  {
    name: "todefang",
    tests: [
      ("http://evil.com" | todefang == "hxxp://evil[.]com"),
      ("https://evil.com" | todefang == "hxxps://evil[.]com"),
      ("attacker@phish.org" | todefang == "attacker[@]phish[.]org"),
      ("192.168.1.1" | todefang == "192[.]168[.]1[.]1")
    ]
  } | .passed = ((.tests | [.[] | select(. == false)] | length) == 0);

# Test fromdefang
def test_fromdefang:
  {
    name: "fromdefang",
    tests: [
      ("hxxp://evil[.]com" | fromdefang == "http://evil.com"),
      ("hxxps://evil[.]com" | fromdefang == "https://evil.com"),
      ("attacker[@]phish[.]org" | fromdefang == "attacker@phish.org"),
      ("192[.]168[.]1[.]1" | fromdefang == "192.168.1.1")
    ]
  } | .passed = ((.tests | [.[] | select(. == false)] | length) == 0);

# Test chaining
def test_chaining:
  {
    name: "chaining",
    tests: [
      (13318523932000000 | fromwebkit | toreadable == "2012-03-15 10:12:12"),
      (1741420298 | fromunix | toreadable == "2025-03-08 09:51:38"),
      ("http://evil.com" | todefang | fromdefang == "http://evil.com")
    ]
  } | .passed = ((.tests | [.[] | select(. == false)] | length) == 0);

# Run all tests
def run_tests:
  [
    test_fromwebkit,
    test_fromcocoa,
    test_fromunix,
    test_toreadable,
    test_todefang,
    test_fromdefang,
    test_chaining
  ];

# Main test runner - output results
run_tests
