var publicityRestrictions = {
    "Public": "MZ.publicityRestrictionsPublic",
    "Protected": "MZ.publicityRestrictionsProtected",
    "Private": "MZ.publicityRestrictionsPrivate"
}

var secureLevel = {
    "none": "MX.secureLevelNone",
    //"KM1": "MX.secureLevelKM1",
    //"KM5": "MX.secureLevelKM5",
    "KM10": "MX.secureLevelKM10",
    //"KM25": "MX.secureLevelKM25",
    //"KM50": "MX.secureLevelKM50",
    //"KM100": "MX.secureLevelKM100",
    //"Highest": "MX.secureLevelHighest",
    //"NoShow": "MX.secureLevelNoShow"
}

var recordBasis = [
            {"enumeration": "HUMAN_OBSERVATION_UNSPECIFIED",
                "property": "MY.recordBasisHumanObservation",
                "label": {
                    "fi": "Havaittu",
                    "en": "Observation",
                    "sv": "Observation"
                }},
            {
                "enumeration": "HUMAN_OBSERVATION_PHOTO",
                "property": "MY.recordBasisHumanObservationPhoto",
                "label": {
                    "fi": "Valokuvattu",
                    "en": "Photographed",
                    "sv": "Fotograferade"
                }
            },
            {
                "enumeration": "HUMAN_OBSERVATION_INDIRECT",
                "property": "MY.recordBasisHumanObservationIndirect",
                "label": {
                    "fi": "Epäsuora havainto (jäljet, ulosteet, yms)",
                    "en": "Indirect observation (footprints, feces, etc)",
                    "sv": "Indirekt observation (fotspår, avföring, etc)"
                }
            },
            {
                "enumeration": "HUMAN_OBSERVATION_HANDLED",
                "property": "MY.recordBasisHumanObservationHandled",
                "label": {
                    "fi": "Käsitelty (otettu kiinni, ei näytettä)",
                    "en": "Handled (catched, not preserved)",
                    "sv": "Behandlad (fasttagit, inte bevarad)"
                }
            },

            {
                "enumeration": "HUMAN_OBSERVATION_RECORDED_AUDIO",
                "property": "MY.recordBasisHumanObservationAudio",
                "label": {
                    "fi": "Äänitetty",
                    "en": "Audio recording",
                    "sv": "Ljudsatt"
                }
            },
            {
                "enumeration": "PRESERVED_SPECIMEN",
                "property": "MY.recordBasisPreservedSpecimen",
                "label": {
                    "fi": "Näyte",
                    "en": "Preserved specimen",
                    "sv": "Prov"
                }
            }
        ]

var taxonConfidence = [
            {
                "enumeration": "SURE",
                "property": "MY.taxonConfidenceSure",
                "label": {
                    "fi": "varma",
                    "en": "sure",
                    "sv": "säker"
                }
            },
            {
                "enumeration": "UNSURE",
                "property": "MY.taxonConfidenceUnsure",
                "label": {
                    "fi": "epävarma",
                    "en": "unsure",
                    "sv": "osäker"
                }
            },
            {
                "enumeration": "SUBSPECIES_UNSURE",
                "property": "MY.taxonConfidenceSubspeciesUnsure",
                "label": {
                    "fi": "alalaji epävarma",
                    "en": "subspecies unsure",
                    "sv": "underart osäker"
                }
            }
        ]

function Document() {
    this.creator = ""
    this.editors = []
    this.formID = "JX.519"
    this.secureLevel = secureLevel.none
    this.publicityRestrictions = publicityRestrictions.Public
    this.gatherings = []
}

function GatheringEvent() {
    this.dateBegin = ""
    this.leg = []
    this.legPublic = true
    this.legUserID = []
    this.timeStart = ""
}

function Gathering() {
    this.coordinateSource = "MY.coordinateSourceGps"
    this.coordinateSystem = "MY.coordinateSystemWgs84"
    this.geometry = {
        "type": "Point",
        "coordinates": []
    }
    this.municipality = ""
    this.locality = ""
    this.localityDescription = ""
    this.dateBegin = ""
    this.units = []
}

function Unit() {
    this.recordBasis = "MY.recordBasisHumanObservation"
    this.identifications = []
    this.count = ""
    this.taxonConfidence = "MY.taxonConfidenceSure"
    this.notes = ""
    this.unitFact = {
        "autocompleteSelectedTaxonID": ""
    }
}

function Identification() {
    this.taxon = ""
    this.taxonID = ""
}
