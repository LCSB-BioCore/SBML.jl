
url = "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/release/cases/semantic/00878/00878-sbml-l3v2.xml"
@test isequal(url, SBML.test_suite_url(878))
m = SBML.readSBMLTestCase(878)
m2 = SBML.readSBMLTestCase(878; level=2, version=4)
@test

id = "MODEL8568434338"
m = SBML.readSBMLBioModel(id)
m = SBML.readSBMLBioModel(id; conv_f=SBML.default_convert_function(3,1))
@test length(m.reactions) == 249
