#include "readsbml.hpp"

struct species_info {
  std::string name;
  std::string compartment;
};

struct unit_part {
  std::string kind;
  int exponent, scale;
  double multiplier;
};

struct reaction {
  std::map<std::string, double> stoichiometry;
  std::pair<double, std::string> lb, ub;
  double oc;

  reaction() : oc(0), lb{-INFINITY, ""}, ub{INFINITY, ""} {}
};

struct model_data {
  std::list<std::string> errors;
  std::map<std::string, std::list<unit_part>> units;
  std::set<std::string> compartments;
  std::map<std::string, species_info> species_compartment;
  std::map<std::string, reaction> reactions;
};

model_data readSBML(const std::string& fn) {
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
    m.units[ud.getName()];
    for (unsigned j = 0; j < ud.getNumUnits(); ++j) {
      Unit& u = *ud.getUnit(j);
      m.units[ud.getName()].emplace_back(
          unit_part{UnitKind_toString(u.getKind()), u.getExponent(),
                    u.getScale(), u.getMultiplier()});
    }
  }

  for (unsigned i = 0; i < model->getNumCompartments(); ++i) {
    Compartment& c = *model->getCompartment(i);
    m.compartments.emplace(c.getId());
  }

  for (unsigned i = 0; i < model->getNumSpecies(); ++i) {
    Species& s = *model->getSpecies(i);
    m.species_compartment[s.getId()] =
        species_info{s.getName(), s.getCompartment()};
  }

  for (unsigned i = 0; i < model->getNumReactions(); ++i) {
    Reaction& r = *model->getReaction(i);
    auto& mr = m.reactions[r.getId()];

    KineticLaw& kl = *r.getKineticLaw();
    for (unsigned j = 0; j < kl.getNumParameters(); ++j) {
      Parameter& p = *kl.getParameter(j);
      if (p.getId() == "LOWER_BOUND") mr.lb = {p.getValue(), p.getUnits()};
      if (p.getId() == "UPPER_BOUND") mr.lb = {p.getValue(), p.getUnits()};
      if (p.getId() == "OBJECTIVE_COEFFICIENT") mr.oc = p.getValue();
    }

    auto saveSpecies = [&mr](double direction, SpeciesReference& sr) {
      mr.stoichiometry[sr.getSpecies()] = direction * sr.getStoichiometry();
    };

    for (unsigned j = 0; j < r.getNumReactants(); ++j)
      saveSpecies(-1, *r.getReactant(j));
    for (unsigned j = 0; j < r.getNumProducts(); ++j)
      saveSpecies(1, *r.getProduct(j));
  }

  return m;
}

void define_readsbml(jlcxx::Module& mod) {
  using namespace cpp_types;

  types.add_type<species_info>("Species");
  types.add_type<unit_part>("UnitPart");
  types.add_type<reaction>("Reaction").constructor();
  types.add_type<model_data>("Model");

  mod.method("readSBML", &readSBML);
}
