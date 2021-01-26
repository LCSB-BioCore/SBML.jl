#include <sbml/SBMLTypes.h>

#include <memory>
#include <string>
#include <tuple>
#include <utility>
#include <vector>

#include "jlcxx/functions.hpp"
#include "jlcxx/stl.hpp"
#include "readsbml.hpp"

struct species_info {
  std::string id;
  std::string name;
  std::string compartment;
};

struct unit_part {
  std::string unit;
  std::string kind;
  int exponent, scale;
  double multiplier;
};

struct stoi {
  std::string id;
  double stoichiometry;
};

struct reaction {
  std::string id;
  std::vector<stoi> species;
  std::tuple<double, std::string> lb, ub;
  double oc;

  reaction() : oc(0), lb{-INFINITY, ""}, ub{INFINITY, ""} {}
};

struct model_data {
  std::vector<std::string> errors;
  std::vector<unit_part> units;
  std::vector<std::string> compartments;
  std::vector<species_info> species;
  std::vector<reaction> reactions;
};

model_data read_sbml(const std::string& fn) {
  model_data m;
  std::unique_ptr<Model> model;

  {
    std::unique_ptr<SBMLDocument> document(readSBML(fn.c_str()));

    if (document->getNumErrors()) {
      for (unsigned i = 0; i < document->getNumErrors(); ++i)
        m.errors.emplace_back(document->getError(i)->getMessage());
      return m;
    }

    model = std::unique_ptr<Model>(document->getModel()->clone());
  }

  for (unsigned i = 0; i < model->getNumUnitDefinitions(); ++i) {
    UnitDefinition& ud = *model->getUnitDefinition(i);
    for (unsigned j = 0; j < ud.getNumUnits(); ++j) {
      Unit& u = *ud.getUnit(j);
      m.units.emplace_back(
          unit_part{ud.getName(), UnitKind_toString(u.getKind()),
                    u.getExponent(), u.getScale(), u.getMultiplier()});
    }
  }

  for (unsigned i = 0; i < model->getNumCompartments(); ++i) {
    Compartment& c = *model->getCompartment(i);
    m.compartments.emplace_back(c.getId());
  }

  for (unsigned i = 0; i < model->getNumSpecies(); ++i) {
    Species& s = *model->getSpecies(i);
    m.species.emplace_back(
        species_info{s.getId(), s.getName(), s.getCompartment()});
  }

  for (unsigned i = 0; i < model->getNumReactions(); ++i) {
    Reaction& r = *model->getReaction(i);
    reaction mr;
    mr.id = r.getId();

    KineticLaw& kl = *r.getKineticLaw();
    for (unsigned j = 0; j < kl.getNumParameters(); ++j) {
      Parameter& p = *kl.getParameter(j);
      if (p.getId() == "LOWER_BOUND") mr.lb = {p.getValue(), p.getUnits()};
      if (p.getId() == "UPPER_BOUND") mr.ub = {p.getValue(), p.getUnits()};
      if (p.getId() == "OBJECTIVE_COEFFICIENT") mr.oc = p.getValue();
    }

    auto saveSpecies = [&mr](double direction, SpeciesReference& sr) {
      mr.species.emplace_back(
          stoi{sr.getSpecies(), direction * sr.getStoichiometry()});
    };

    for (unsigned j = 0; j < r.getNumReactants(); ++j)
      saveSpecies(-1, *r.getReactant(j));
    for (unsigned j = 0; j < r.getNumProducts(); ++j)
      saveSpecies(1, *r.getProduct(j));
    m.reactions.emplace_back(std::move(mr));
  }

  return m;
}

void define_readsbml(jlcxx::Module& mod) {
  mod.add_type<species_info>("Species");
  mod.add_type<unit_part>("UnitPart");
  mod.add_type<stoi>("Stoichiometry");
  mod.add_type<reaction>("Reaction").constructor();
  mod.add_type<model_data>("Model");

  mod.method("readSBML", &read_sbml);

#define access(t, n) mod.method(#n, [](const t& x) { return x.n; })

  access(species_info, id);
  access(species_info, name);
  access(species_info, compartment);

  access(unit_part, unit);
  access(unit_part, kind);
  access(unit_part, exponent);
  access(unit_part, scale);
  access(unit_part, multiplier);

  access(stoi, id);
  access(stoi, stoichiometry);

  access(reaction, id);
  access(reaction, species);
  access(reaction, lb);
  access(reaction, ub);
  access(reaction, oc);

  access(model_data, errors);
  access(model_data, units);
  access(model_data, compartments);
  access(model_data, species);
  access(model_data, reactions);
}
