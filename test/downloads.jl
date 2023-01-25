
url = "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/release/cases/semantic/00878/00878-sbml-l3v2.xml"
@test isequal(url, SBML.test_suite_url(878))
m = SBML.readSBMLTestCase(878)
m2 = SBML.readSBMLTestCase(878; level=2, version=4)
